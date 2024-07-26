#!/usr/bin/env ruby

require 'date'
require 'optparse'

DAY_OF_WEEK = 'Su Mo Tu We Th Fr Sa'
ONE_WEEK_DAYS = 7
SPACE_WIDTH = 3

begin
  options = ARGV.getopts('y:m:')
rescue OptionParser::InvalidOption
  puts '指定できるオプションは -m (1-12月) と -y (年4桁) です。'
  exit
end

year = options['y'].nil? ? Date.today.year : options['y'].to_i

month = options['m'].nil? ? Date.today.mon : options['m'].to_i

if month < 1 || month > 12
  puts '月は 1-12 で指定して下さい。'
  exit
end

first_day = Date.new(year, month, 1)
end_day = Date.new(year, month, -1)

# 曜日のタイトルの長さをカレンダーのサイズにする。
calendar_width = DAY_OF_WEEK.length

month_name = first_day.strftime('%B')
calendar_title = "#{month_name} #{year}"
puts calendar_title.center(calendar_width)

puts DAY_OF_WEEK

initial_space_counts = (first_day.cwday % ONE_WEEK_DAYS) * SPACE_WIDTH
print ' ' * initial_space_counts

(first_day..end_day).each do |day|
  print day.day.to_s.rjust(2)
  if day.saturday? || day == end_day
    puts
  else
    print ' '
  end
end
puts
