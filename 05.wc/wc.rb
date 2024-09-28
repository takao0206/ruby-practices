#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

MAX_COLUMN_WIDTH = 7
EMPTY_OUTPUT = ''

def main
  totals = { line_counts: 0, word_counts: 0, byte_counts: 0 }

  options = parse_command_line[:options]
  paths = parse_command_line[:args]

  if paths.empty?
    print_text_size([$stdin.read], options)
  else
    column_width =
      if paths.any? { |path| File.directory?(path) }
        MAX_COLUMN_WIDTH
      else
        calculate_column_width(paths, totals) || 0
      end

    print_entry_size(paths, options, column_width)
    print_totals(totals, options, column_width) if paths.size > 1
  end
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

# ファイルパスに対して、各アイテム（行数、文字数、バイト数）の最大列幅を計算する。
#
# @param [Array] filepaths ファイルパス
# @param [Hash] totals 各アイテムの累積値
# @return [Integer] 最大列幅
def calculate_column_width(filepaths, totals)
  filepaths.map do |filepath|
    next unless File.file?(filepath)

    item_length = calculate_content_size(extract_content(filepath))

    totals[:line_counts] += item_length[:line_counts]
    totals[:word_counts] += item_length[:word_counts]
    totals[:byte_counts] += item_length[:byte_counts]

    totals.values.map { |item| item.to_s.length }.max
  end.compact.max
end

# 入力されたパスの内容を取得する。
#
# @param [String] path パス
# @return [String] ファイルパスが入力されれば、その中身を出力する。
# @return [String] ディレクトリパスが入力されれば、''(EMPTY_OUTPUT)を出力する。
def extract_content(path)
  return File.read(path) if File.file?(path)

  EMPTY_OUTPUT if File.directory?(path)
end

# 入力されたパスに対して、行数、文字数、バイト数を計算する。
#
# @param [String] path パス
# @return [Hash] 行数、文字数、バイト数を計算する。
def calculate_content_size(path)
  {
    line_counts: path.count("\n"),
    word_counts: path.split(/[\s\u3000]/).count { |element| !element.empty? },
    byte_counts: path.bytesize
  }
end

# 各アイテムの列幅を整えて出力する。もしパスが存在しない場合は、エラーメッセージを出力する。
#
# @param [Array] paths ファイルまたはディレクトリのパス
# @param [Hash] options コマンドラインのオプション
# @param [Integer] column_width 列幅
def print_entry_size(paths, options, column_width)
  paths.each do |path|
    if File.file?(path) || File.directory?(path)
      calculated_items = calculate_content_size(extract_content(path))
      selected_items = select_items(calculated_items, options)

      justified_items = justify_items(selected_items, paths, options, column_width)
      justified_items << path

      puts "wc: #{path}: Is a directory" if File.directory?(path)
      puts justified_items.join(' ')
    else
      puts "wc: #{path}: No such file or directory"
    end
  end
end

# 条件に従い、アイテム（行数、文字数、バイト数）を揃える
#
# @param [Hash] items アイテム
# @param [Array] paths パス
# @param [Array] options コマンドラインの引数
# @param [Integer] column_width 列幅
# @return [Array] 列幅を揃えたアイテム
def justify_items(items, paths, options, column_width)
  items.values.map do |item|
    if paths.size > 1
      item.to_s.rjust(column_width)
    elsif options.values.count(true) != 1
      item.to_s.rjust(column_width)
    else
      item.to_s
    end
  end
end

# テキストに対して、各アイテムの列幅を整えて出力する。
#
# @param [Array] text テキスト
# @param [Hash] options コマンドラインのオプション
def print_text_size(text, options)
  calculated_items = calculate_content_size(text.first)
  selected_items = select_items(calculated_items, options)

  justified_items = selected_items.values.map do |item|
    if options.values.count(true) == 1
      item.to_s
    else
      item.to_s.rjust(MAX_COLUMN_WIDTH)
    end
  end

  puts justified_items.join(' ')
end

# コマンドライン引数のオプションに従いアイテム（行数、文字数、バイト数）を出力する。
#
# @param [Hash] items アイテム
# @param [Hash] options コマンドラインで指定されたオプション
# @return [Hash] 選択されたアイテムを出力する。オプションの指定がない場合、全てのアイテムを出力する。
def select_items(items, options)
  selected_items = {}

  selected_items[:line_counts] = items[:line_counts] if options[:l]
  selected_items[:word_counts] = items[:word_counts] if options[:w]
  selected_items[:byte_counts] = items[:byte_counts] if options[:c]

  selected_items = items if selected_items.empty?

  selected_items
end

# 各アイテム（行数、文字数、バイト数）の合計値を、列幅を揃えて出力する。
#
# @param [Hash] totals 各アイテムの合計値
# @param [Hash] options コマンドラインのオプション
# @param [Integer] column_width 各アイテムの列幅
def print_totals(totals, options, column_width)
  selected_total_items = select_items(totals, options)

  justified_total_items = selected_total_items.values.map { |item| item.to_s.rjust(column_width) }
  justified_total_items << 'total'

  puts justified_total_items.join(' ')
end

main
