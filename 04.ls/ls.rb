#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

# ls で表示されるエントリは3列にする
COLUMNS = 3

def main
  arguments = fetch_arguments

  # コマンドライン引数のパスが2つ以上ある場合、
  # まずファイルをアルファベット順に並べ、次にディレクトリをその順に並べて、表示する。
  arguments[:paths].sort_by! { |path| [File.file?(path) ? 0 : 1, path.downcase] }.each do |path|
    entries = search_entries(path)
    next if entries.nil?

    entries.reject! { |entry| entry.start_with?('.') }
    entries.sort!.map { |entry| File.directory?(File.join(path, entry)) ? entry << '/' : entry }

    display_output(entries)
  end
end

# コマンドライン引数を取得する。想定外の引数が入力された場合、エラーを返す。
#
# @return [Hash] 取得した引数がハッシュの形式で出力される。
def fetch_arguments
  arguments = { paths: [] }

  # TODO: 今後のプラクティスで、オプション-a, -r, -lを以下に追加する予定。
  opts = OptionParser.new

  begin
    opts.parse!(ARGV)
  rescue OptionParser::InvalidOption => e
    puts e.message
    exit 2
  end

  arguments[:paths] = ARGV.empty? ? [Dir.pwd] : ARGV

  arguments
end

# 指定されたパスのファイルエントリを検索する。
#
# @param path [String] ファイルエントリを検索したいパス
# @return [Array] ファイルエントリを配列で返す。
# @return 指定されたパスがファイルだった時は、ファイルのフルパスを返す。
# @return 指定されたパスが見つからなかった時やアクセス不可の時は、nilを返す。
def search_entries(path)
  Dir.entries(path)
rescue Errno::ENOENT
  puts "cannot access '#{path}': No such file or directory"
rescue Errno::EACCES
  puts "cannot open '#{path}': Permission denied"
rescue Errno::ENOTDIR
  [path]
end

# 列幅を整えたファイルエントリをマトリクスで表示する。
#
# @param entries [Array] ファイルエントリ
def display_output(entries)
  max_col_length = entries.map(&:length).max

  rows = (entries.size.to_f / COLUMNS).ceil
  output_matrix = Array.new(rows) { [] }

  entries.each_with_index do |entry, index|
    row = index % rows
    col = index / rows
    output_matrix[row][col] = entry.ljust(max_col_length)
  end

  puts output_matrix.map { |array| array.join(' ') }.join("\n")
end

main
