#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

MAX_COLUMN_WIDTH = 7
EMPTY_OUTPUT = ''

def main
  totals = { line_counts: 0, word_counts: 0, byte_counts: 0 }

  options = parse_command_line[:options]
  paths = parse_command_line[:args].empty? ? [$stdin.read] : parse_command_line[:args]
  column_width = calculate_column_width(paths, totals)

  print_each_content_size(paths, options, column_width)
  print_totals(totals, options, column_width) if paths.size > 1
end

# コマンドラインからオプションと引数を解析し、取得する。
#
# @return [Hash] オプションと引数を含む:
#   - コマンドラインで指定されたオプションがある場合、 `:options` は `true` を返す。
#     例: `-l` が指定された場合、 `{ l: true, w: false, c: false }` のように返される。
#   - オプション以外の引数（ファイルパスなど）がある場合、 `:args` は配列を返す。
#     例: ['file1.txt', 'file2.txt']
#
# もし無効なオプションが指定された場合、エラーメッセージを表示し、プログラムを終了する。
def parse_command_line
  options = { l: false, w: false, c: false }

  opts = OptionParser.new do |opt|
    opt.on('-l', 'print the newline counts') { options[:l] = true }
    opt.on('-w', 'print the word counts') { options[:w] = true }
    opt.on('-c', 'print the byte counts') { options[:c] = true }
  end

  begin
    opts.parse(ARGV)
  rescue OptionParser::InvalidOption
    puts 'Invalid Option'
    puts opts.help
    exit 1
  end

  args = opts.parse(ARGV.dup)

  { options:, args: }
end

# 指定されたパスに対して、行数、文字数、バイト数の最大列幅を計算する。
# ディレクトリや存在しないファイルの場合は、最大列幅（`MAX_COLUMN_WIDTH`）を使用する。
#
# @param [Array] paths ファイルまたはディレクトリのパスの配列
# @param [Hash] totals 現在までの累積値を含むハッシュ
# @return [Integer] 各パスに基づいて計算された最大列幅
def calculate_column_width(paths, totals)
  paths.map do |path|
    if File.file?(path)
      item_length = calculate_content_size(extract_content(path))

      totals[:line_counts] += item_length[:line_counts]
      totals[:word_counts] += item_length[:word_counts]
      totals[:byte_counts] += item_length[:byte_counts]

      totals.values.map { |item| item.to_s.length }.max
    else
      MAX_COLUMN_WIDTH
    end
  end.max
end

# 入力されたパスに対して、行数、文字数、バイト数を返す。
#
# @param [String] パス
# @return [Hash] 行数、文字数、バイト数を返す。
def calculate_content_size(path)
  {
    line_counts: path.count("\n"),
    word_counts: path.split(/[\s\u3000]/).count { |element| !element.empty? },
    byte_counts: path.bytesize
  }
end

# 入力されたパスに対して、行数、文字数、バイト数を計算し、
# コマンドラインから取得したオプションに合わせてアイテム（行数、文字数、バイト数）を選択し、
# 各アイテムの列幅を整えて出力する。
# もしパスが存在しない場合は、エラーメッセージを出力する。
#
# @param [Array] paths 出力対象のファイルまたはディレクトリのパスの配列
# @param [Hash] options コマンドラインから指定されたオプション
# @param [Integer] column_width 各wcのアイテムを整形するための列幅
def print_each_content_size(paths, options, column_width)
  paths.each do |path|
    if File.exist?(path)
      calculated_items = calculate_content_size(extract_content(path))
      selected_items = select_items(calculated_items, options)

      justified_items = justify_items(selected_items, column_width, path)
      puts justified_items.join(' ')
    else
      puts "wc: #{path}: No such file or directory"
    end
  end
end

# パスの内容を取得する。
#
# @param [String] ファイルやディレクトリのパス、またはテキスト
# @return [String] ファイルパスが入力されれば、その中身を出力する。
# @return [String] ディレクトリパスが入力されれば、''(EMPTY_OUTPUT)を出力する。
# @return [String] テキストが入力されれば、そのまま出力する。
def extract_content(path)
  return File.read(path) if File.file?(path)

  if File.directory?(path)
    puts "wc: #{path}: Is a directory"
    return EMPTY_OUTPUT
  end

  path
end

# パスのアイテム（行数、文字数、バイト数）の列幅を整える。
#
# @param [Hash] items アイテム
# @param [Integer] column_width アイテムの列幅
# @param [String] path ファイルまたはディレクトリのパス
# @return [Array] 列幅を整えたアイテム
def justify_items(items, column_width, path)
  if File.file?(path) || File.directory?(path)
    justified_items = items.values.map { |item| item.to_s.rjust(column_width) }
    justified_items << path
  else
    justified_items = selected_items.values.map do |item|
      item.to_s.send(selected_items.size == 1 ? :ljust : :rjust, column_width)
    end
  end
  justified_items
end

# コマンドライン引数のオプションに従いアイテム（行数、文字数、バイト数）を出力する。
#
# @param [Hash] items アイテム
# @param [Hash] options コマンドライン引数
# @return [Hash] 選択されたアイテムを出力する。オプションの指定がない場合、全てのアイテムを出力する。
def select_items(items, options)
  selected_items = {}

  selected_items[:line_counts] = items[:line_counts] if options[:l]
  selected_items[:word_counts] = items[:word_counts] if options[:w]
  selected_items[:byte_counts] = items[:byte_counts] if options[:c]

  selected_items = items if selected_items.empty?

  selected_items
end

# 各アイテム（行数、文字数、バイト数）の合計値を、列幅を整えて出力する。
#
# @param [Hash] totals 各アイテムの合計値
# @param [Hash] options コマンドラインから指定されたオプション
# @param [Integer] column_width 各アイテムの列幅
def print_totals(totals, options, column_width)
  selected_total_items = select_items(totals, options)
  justified_total_items = selected_total_items.values.map { |item| item.to_s.rjust(column_width) }
  justified_total_items << 'total'
  puts justified_total_items.join(' ')
end

main
