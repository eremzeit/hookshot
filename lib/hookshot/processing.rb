require 'anemone'
require 'mongo'
require 'pry'
require 'logger'

# Reads the output of anemone and does some processing and then
# dumps the result into an output database.
class RawPageProcessor

  attr_accessor :source_db, :dest_db, :client, :counter

  def self.process(source_db_name, source_name)
    p = RawPageProcessor.new(source_db_name, source_name)
    p.process_each
    p
  end

  def initialize(source_db_name, source_name)
    @source_db_name = source_db_name
    @source_name = source_name
    @counter = WordCounter.new
    initialize_db
  end

  def initialize_db
    self.client = Mongo::MongoClient.new("localhost")
    self.source_db = client.db(@source_db_name)
    self.dest_db = client.db(dest_database_name)
  end

  def source_database_name
    raise NotImplementedError.new
  end

  def dest_database_name
    'newsmontage'
  end

  def dest_collection_name
    'documents'
  end

  def pages_coll
    dest_db['pages']
  end

  def freq_coll
    dest_db['frequencies']
  end

  def process_each
    source_db['pages'].find('body' => {'$ne' => nil}).each do |page|

      body_html = page['body'].to_s
      result = TextExtractor.extract(body_html)

      if result.is_article?
        page_word_counts = counter.process(result.text)

        puts "Inserted #{page['url']}"

        # Remove any previous documents created for this
        pages_coll.remove( { 'url' =>  page['url'] })

        pages_coll.insert({
          "url" => page['url'],
          "body" => page['html'],
          "text" => result.text,
          "source" => @source_name
        })

        freq_coll.remove( { 'url' =>  page['url'] })
        freq_coll.insert({
          'url' => page['url'],
          'freqs' => page_word_counts
        })
      end
    end
  end
end

class WordCounter

  def initialize(counts=nil)
    @counts = counts || Hash.new(0)
  end

  # a hash of words to counts
  def increment(counts)
    counts.keys.each do |word|
      @counts[word] += counts[word]
    end
  end

  def counts
    @counts
  end

  def reset
    @counts = Hash.new(0)
  end

  def self.combine(counters)
    counts = Hash.new(0)

    counters.each do |counter|
      counter.counts.keys.each do |word|
        counts[word] += counter.counts[word]
      end
    end

    WordCounter.new(counts)
  end

  def process(text)
    counts = Hash.new(0)
    words = text.gsub(/[^A-Za-z]/, ' ').downcase.split

    words.each do |word|
      counts[normalize_word(word)] += 1
    end

    increment(counts)

    #return the counts for this particular text
    counts
  end

  #generally, we want to count word frequencies by the root form of the
  #word and ignore the effect of different forms
  def normalize_word(word)
    word.to_s.to_sym
  end


  def sorted_pairs
    @counts.to_a.sort_by {|x| x[1] }.reverse
  end

  def normalized_sorted_pairs
    counts = @counts.to_a
    sum = counts.map{|x| x[1] }.inject{|sum,x| sum + x }
    counts.map! {|x| x[1] = x[1].to_f / sum.to_f; x}
    counts = counts.sort_by {|x| x[1] }.reverse
  end

  def dump_to_file(count = 1000)
    f = File.open('./word_frequencies.csv', 'w')
    pairs = normalized_sorted_pairs[(0...count)]
    pairs.each do |pair|
      f.write("#{pair[0]},#{sprintf("%.5f", pair[1])}\n")
    end

    f.close
  end
end
