require 'rubygems'
$: << 'lib'
require 'lib/hookshot'

counter = WordCounter.new

args = [
  ['montage7495', 'cnn'],
  ['montage6039', 'aljazeera'],
  ['montage2958', 'fox']
]

args.each do |pair|
  p = RawPageProcessor.process(*pair)
  counter = WordCounter.combine([counter, p.counter])
end


require 'pry'; binding.pry
counter.dump_to_file
require 'pry'; binding.pry

