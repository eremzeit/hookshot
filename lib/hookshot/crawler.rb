class Crawler
  def setup_db(dbname)
    mongo_client = Mongo::MongoClient.new("localhost", 27017).db(dbname)
  end

  def start_crawl(homepage_url, name)
    Anemone.crawl(homepage) do |anemone|
      anemone.storage = Anemone::Storage.MongoDB(setup_db(name))
      anemone.on_every_page do |page|
        if page.code.to_s =~ /2../
          puts "FETCHED: #{page.url}"
        else
          puts "ERROR: #{page.body}"
        end
      end
    end
  end

  def crawl_all
    pages = [
      ['http://www.cnn.com', 'cnn'],
      ['http://www.foxnews.com', 'fox'],
      ['http://www.aljazeera.com/', 'aljazeera'],
      ['http://www.bbc.com', 'bbc'],
      ['http://www.huffingtonpost.com', 'huffingtonpost'],
    ]

    pages.each {|page| start_crawl(*page)}
  end
end
