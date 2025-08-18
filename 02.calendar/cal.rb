#!/bin/env ruby
require 'optparse'
require 'date'

# 引数を指定しない場合に、今月・今年を返す
month = Date.today.month
year = Date.today.year

# 年・月を受け取り、表示したい月の最初の日と最後の日を取得する
opt = OptionParser.new
opt.on('-m [VAL]') {|v| month = v.to_i}
opt.on('-y [VAL]') {|v| year = v.to_i}
opt.parse!(ARGV)
first_date = Date.new(year, month, 1)
last_date = Date.new(year, month, -1)

puts "#{month}月 #{year}".center(20)  
puts "日 月 火 水 木 金 土"

print "   " * first_date.wday
(first_date..last_date).each {|date|
  #日付が一桁のため日付の前にスペースを追加して表示し、土曜日なので改行
  if  (date.day < 10 && date.wday) == 6
    puts " #{date.day}"
  #日付が一桁のため日付の前にもスペースを追加して表示
  elsif date.day < 10
    print " #{date.day} "
  #土曜日なので改行
  elsif date.wday == 6
    puts date.day
  else
    print "#{date.day} "
  end
}

