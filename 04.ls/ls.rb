#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'

# ls で表示されるエントリは3列にする
COLUMNS = 3

def main
  options = parse_command_line_options
  entries = fetch_file_entries(options[:a], options[:r])

  if options[:l]
    display_total_block_kbyte(entries)
    file_details = build_file_details(entries)

    max_col_lengths = file_details.transpose.map do |col|
      col.map { |item| item.to_s.length }.max
    end

    display_output_for_option_l(file_details, max_col_lengths)
  else
    display_output(entries)
  end
end

# コマンドラインから指定されたオプションを解析し、取得する。
#
# @return [Hash] 解析されたオプションがキーと値のペアでハッシュとして返される。
#                例えば、`-a` オプションが指定された場合、 `{ a: true }` が返される。
#                オプションが指定されない場合、デフォルトで `{ a: false }` が返される。
#                また、無効なオプションが指定された場合は、エラーメッセージを表示し、プログラムを終了する。
def parse_command_line_options
  options = { a: false, r: false, l: false }

  opts = OptionParser.new do |opt|
    opt.on('-a', 'do not ignore entries starting with .') { options[:a] = true }
    opt.on('-r', 'reserse order while sorting') { options[:r] = true }
    opt.on('-l', 'use a long listing format') { options[:l] = true }
  end

  begin
    opts.parse(ARGV)
  rescue OptionParser::InvalidOption
    puts 'Invalid Option'
    puts opts.help
    exit 1
  end

  options
end

# オプションに基づいてエントリを表示する。
#
# @param show_all [Boolean] ドットで始まるファイルやディレクトリを表示するかどうかを指定する。
# @param reverse_order [Boolean] エントリを逆順にソートするかどうかを指定する。
# @return [Array] 取得されたディレクトリエントリの配列が返される。
#                 オプションに応じてフィルタリングとソートが適用される。
#                 例えば、`show_all` が `true` の場合はすべてのエントリが含まれる。
def fetch_file_entries(show_all, reverse_order)
  entries = Dir.entries(Dir.pwd).sort
  entries.reject! { |entry| entry.start_with?('.') } unless show_all
  entries.reverse! if reverse_order
  entries
end

# カレントディレクトリ内のファイルエントリの合計容量（キロバイト）を表示する。
#
# @param entries [Array] ファイルエントリ
# @return [Integer] カレントディレクトリ内の全容量（キロバイト）
def display_total_block_kbyte(entries)
  kbyte_per_block = 512 / 1024.to_f

  total_kbytes = entries.map do |entry|
    (File.lstat(File.join(Dir.pwd, entry)).blocks * kbyte_per_block).floor
  end.compact.sum
  puts "total #{total_kbytes}"
end

# 各ファイルエントリの詳細情報を配列で返す。
#
# @param entries [Array] ファイルエントリ
# @return [Array] 各ファイルエントリの詳細情報
def build_file_details(entries)
  file_details = []

  entries.each do |entry|
    entry_stat = File.lstat(File.join(Dir.pwd, entry))

    file_details << [
      convert_filetype_to_char(entry_stat.ftype),
      convert_octal_to_rwx(entry_stat.mode.to_s(8)[-3..].chars),
      entry_stat.nlink,
      Etc.getpwuid(entry_stat.uid).name,
      Etc.getgrgid(entry_stat.gid).name,
      entry_stat.size,
      entry_stat.mtime.strftime('%b %d %H:%M'),
      entry_stat.symlink? ? "#{entry} -> #{File.readlink(entry_stat)}" : entry
    ]
  end
  file_details
end

# ファイルタイプを1文字で表現する。
#
# @param ftype [String] ファイルタイプ
# @return [String] ファイルタイプを示す1文字
def convert_filetype_to_char(ftype)
  case ftype
  when 'file' then '-'
  when 'fifo' then 'p'
  else ftype.chr
  end
end

# オクタル表記のパーミッションを rwx 表記に変換する。
#
# @param octal_permissions [Array] 各文字は '0' から '7' のいずれか
# @return [String] rwx 表記に変換されたパーミッションの文字列
def convert_octal_to_rwx(octal_permissions)
  permissions_map = {
    '7' => 'rwx',
    '6' => 'rw-',
    '5' => 'r-x',
    '4' => 'r--',
    '3' => '-wx',
    '2' => '-w-',
    '1' => '--x',
    '0' => '---'
  }

  octal_permissions.map { |octal| permissions_map[octal] || '???' }.join
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

# 列幅を整えたマトリックスで表示する。オプション-l用
#
# @param file_details [Array] 出力表示に使われる各ファイルの情報
# @param col_lengths [Array] 出力表示の各列の長さ
def display_output_for_option_l(file_details, max_col_lengths)
  file_details.each do |row|
    row.each_with_index do |file_detail, index|
      if index.zero?
        print file_detail.to_s.ljust(max_col_lengths[index])
      elsif file_detail.is_a?(Numeric)
        print "#{file_detail.to_s.rjust(max_col_lengths[index])} "
      else
        print "#{file_detail.to_s.ljust(max_col_lengths[index])} "
      end
    end
    puts
  end
end

main
