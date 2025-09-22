#!/bin/env ruby
require 'optparse'
require 'date'

# 今日の日付を取得
today = Date.today

# 引数を指定しない場合に、今月・今年を返す
month = today.month
year = today.year

# 年・月を受け取り、表示したい月の最初の日と最後の日を取得する
opt = OptionParser.new
opt.on('-m [VAL]') { |v| month = v.to_i }
opt.on('-y [VAL]') { |v| year = v.to_i }
opt.parse!(ARGV)
first_date = Date.new(year, month, 1)
last_date = Date.new(year, month, -1)

puts "#{month}月 #{year}".center(20)
puts '日 月 火 水 木 金 土'

print '   ' * first_date.wday

(first_date..last_date).each do |date|
  if date.saturday?
    puts date.day.to_s.rjust(2)
  else
    print "#{date.day} ".rjust(3)
  end
end
