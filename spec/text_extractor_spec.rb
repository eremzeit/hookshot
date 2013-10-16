require 'spec_helper'

describe TextExtractor do
  let (:html) do
    f = File.open('spec/samples/news_article1.html')
    _html = f.read
    f.close
    _html
  end

  it 'can make a call to boilerpipe' do
    r = TextExtractor.extract(html)
    r.class.should == TextExtractor
    r.text.class.should == String
    (r.text.length > 20).should be_true
  end
end
