describe WordCounter do
  it 'adds counts' do
    counter = WordCounter.new
    counter.increment({
      :dog => 5,
      :log => 5,
      :bog => 5
    })

    counter.increment({
      :cat => 5,
      :dog => 5,
      :log => 5
    })

    count = counter.counts
    count[:cat].should == 5
    count[:dog].should == 10
    count[:log].should == 10
    count[:bog].should == 5
  end

  it 'combines counters' do
    counter1 = WordCounter.new
    counter1.increment({
      :socks => 5,
    })

    counter2 = WordCounter.new
    counter2.increment({
      :socks => 5
    })

    combined = WordCounter.combine([counter1, counter2])
    combined.counts[:socks].should == 10
  end
end
