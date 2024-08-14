#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

# ls で表示されるエントリは3列にする
COLUMNS = 3

def main
  # プログラムの引数（ファイルパス、オプション等）が複数あることを想定して、引数をハッシュに格納する。
  arguments = {
    paths: ARGV.empty? ? [Dir.pwd] : ARGV
  }

  arguments[:paths].each do |path|
    if File.file?(path)
      puts "#{path}\n\n"
      next
    elsif arguments[:paths].length > 1
      puts "#{path}:"
    end

    entries = fetch_entries(path)
    next if entries.nil?

    sorted_entries = entries.sort
    sorted_entries.map { |entry| entry << '/' if File.directory?(File.join(path, entry)) }
    # 隠しファイルやディレクトリを削除する
    sorted_entries.reject! { |entry| entry.start_with?('.') }

    output_matrix = build_output_matrix(sorted_entries)

    puts output_matrix.map { |array| array.join(' ') }.join("\n")
    puts
  end
end

# 指定されたパスのファイルエントリを抽出する
#
# @param path [String] ディレクトリのパス
# @return [Array] ファイルエントリを配列で返す。
# @return ファイルやアクセス可のディレクトリ以外が入力されると、nilとメッセージが返る。
def fetch_entries(path)
  Dir.entries(path)
rescue Errno::ENOENT
  puts "cannot access '#{path}': No such file or directory\n\n"
rescue Errno::EACCES
  puts "cannot open '#{path}': Permission denied\n\n"
rescue Errno::ENOTDIR
  puts "cannot list entries for '#{path}': Not a directory\n\n"
end

# マトリックスで出力表示を作る
#
# @param entries [Array] ファイルエントリの配列
def build_output_matrix(entries)
  max_column_length = entries.map(&:length).max
  rows = (entries.size.to_f / COLUMNS).ceil

  output_matrix = Array.new(rows) { [] }
  entries.each_with_index do |entry, index|
    row = index % rows
    col = index / rows
    output_matrix[row][col] = entry.ljust(max_column_length)
  end
  output_matrix
end

main
