#!/usr/bin/env ruby

require 'date'
require 'optparse'

# ユーザの入力値（年月）を取得する。
begin
  options = ARGV.getopts('y:m:')
rescue OptionParser::InvalidOption
  puts '指定できるオプションは -m (1-12月) と -y (年4桁) です。'
  exit
end

# 出力するカレンダーの年。
year = options['y'].nil? ? Date.today.year : options['y'].to_i

# 出力するカレンダーの月。
month = options['m'].nil? ? Date.today.mon : options['m'].to_i

# 月が1月から12月以外の場合、再入力を促すメッセージを返す。
if month < 1 || month > 12
  puts '月は 1-12 で指定して下さい。'
  exit
end

# カレンダー1か月分の日を作る。
first_day = Date.new(year, month, 1)
end_day = Date.new(year, month, -1)
month_range = first_day..end_day

# 出力するカレンダーのサイズ（幅）を曜日のタイトルの幅にする。
Day_of_week = ' Su Mo Tu We Th Fr Sa'
calendar_width = Day_of_week.length

# カレンダーのタイトル（月年）を表示する。
month_name = first_day.strftime('%B')
calendar_title = "#{month_name} #{year}"
puts calendar_title.center(calendar_width)

# カレンダーの曜日を表示する。
puts Day_of_week

# カレンダーの一日とその曜日が合致するまで空白を入れる。
one_week_days = 7
space_width = 3
initial_space_counts = (first_day.cwday % one_week_days) * space_width
print ' ' * initial_space_counts

# カレンダーとして一日～月末まで表示する。
month_range.each do |day|
  print format('%3d', day.day)
  # 土曜日で改行する。
  print("\n") if day.saturday?
end
print("\n")
