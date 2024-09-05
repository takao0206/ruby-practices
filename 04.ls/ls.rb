#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

# ls で表示されるエントリは3列にする
COLUMNS = 3

def main
  options = parse_command_line_options
  entries = Dir.entries(Dir.pwd).sort
  entries.reject! { |entry| entry.start_with?('.') } unless options[:a]

  display_output(entries)
end

# コマンドラインから指定されたオプションを解析し、取得する。
#
# @return [Hash] 解析されたオプションがキーと値のペアでハッシュとして返される。
#                例えば、`-a` オプションが指定された場合、 `{ a: true }` が返される。
#                オプションが指定されない場合、デフォルトで `{ a: false }` が返される。
#                また、無効なオプションが指定された場合は、エラーメッセージを表示し、プログラムを終了する。
def parse_command_line_options
  options = { a: false }

  opts = OptionParser.new
  opts.on('-a', 'do not ignore entries starting with .') { options[:a] = true }

  begin
    opts.parse(ARGV)
  rescue OptionParser::InvalidOption
    puts 'Invalid Option'
    puts opts.help
    exit 1
  end

  options
end

# 列幅を整えたファイルエントリをマトリクスで表示する。
#
# @param entries [Array] ファイルエントリ
def display_output(entries)
  max_col_length = entries.map(&:length).max

  rows = (entries.size.to_f / COLUMNS).ceil
  output_matrix = Array.new(rows) { [] }

  entries.each_with_index do |entry, index|
    row = index.divmod(rows)[1]
    col = index.divmod(rows)[0]
    output_matrix[row][col] = entry.ljust(max_col_length)
  end

  puts output_matrix.map { |array| array.join(' ') }.join("\n")
end

main
