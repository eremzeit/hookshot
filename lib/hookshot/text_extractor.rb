require 'nokogiri'

#TextBlock = Java::De.l3s.boilerpipe.document.TextBlock
#TextDocument = Java::De.l3s.boilerpipe.document.TextDocument
ArticleExtractor = Java::de.l3s.boilerpipe.extractors.ArticleExtractor

class TextExtractor
  attr_accessor :text

  def self.extract(body_html)
    e = TextExtractor.new(body_html)
  end

  def initialize(body_html)
    @html = body_html
    html_to_text
  end

  def html_to_text
    extractor = ArticleExtractor.getInstance()
    @text = extractor.getText(@html)
  end

  def is_article?
    @text.length > 100
  end
end
