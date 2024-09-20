#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'

# ls で表示されるエントリは3列にする
COLUMNS = 3
KBYTE_PER_BLOCK = 512 / 1024.to_f

def main
  options = parse_command_line_options
  entries = fetch_file_entries(options[:a], options[:r])

  if options[:l]
    display_total_block_kbyte(entries)
    file_details = build_file_details(entries)

    max_col_lengths = {}
    file_details[0].each_key do |key|
      max_col_lengths[key] = file_details.map { |item| item[key].to_s.length }.max
    end

    display_in_long_format(file_details, max_col_lengths)
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
  total_kbytes = entries.map do |entry|
    (File.lstat(File.join(Dir.pwd, entry)).blocks * KBYTE_PER_BLOCK).floor
  end.compact.sum
  puts "total #{total_kbytes}"
end

# 各ファイルエントリの詳細情報（ハッシュ）を配列で返す。
#
# @param entries [Array] ファイルエントリ
# @return [Array] 各ファイルエントリの詳細情報
def build_file_details(entries)
  file_details = []

  entries.each do |entry|
    entry_stat = File.lstat(File.join(Dir.pwd, entry))

    file_details << {
      type: convert_filetype_to_char(entry_stat.ftype),
      permissions: convert_octal_to_rwx(entry_stat.mode.to_s(8).slice(-4, 4).chars),
      nlink: entry_stat.nlink,
      user: Etc.getpwuid(entry_stat.uid).name,
      group: Etc.getgrgid(entry_stat.gid).name,
      size: entry_stat.size,
      mtime: entry_stat.mtime.strftime('%b %d %H:%M'),
      name: entry_stat.symlink? ? "#{entry} -> #{File.readlink(entry)}" : entry
    }
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

# オクタル表記のパーミッションを rwx 表記 (特殊ビット含む) に変換する。
#
# @param octal_permissions [Array] 各文字は '0' から '7' のいずれか
# @return [String] rwx 表記 (特殊ビットはs, S, t, T) に変換されたパーミッションの文字列
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

  special_bit = octal_permissions[0].to_i
  user_rwx = permissions_map[octal_permissions[1]]
  group_rwx = permissions_map[octal_permissions[2]]
  other_rwx = permissions_map[octal_permissions[3]]

  user_rwx = transform_special_bit(user_rwx, special_bit & 4 != 0, 's', 'S')
  group_rwx = transform_special_bit(group_rwx, special_bit & 2 != 0, 's', 'S')
  other_rwx = transform_special_bit(other_rwx, special_bit & 1 != 0, 't', 'T')
  "#{user_rwx}#{group_rwx}#{other_rwx}"
end

# 特殊ビットの変換を行う
#
# @param rwx [String] 標準の rwx 表記
# @param condition [Boolean] 特殊ビットの条件が真かどうか
# @param set [String] x の場合の置換文字
# @param unset [String] x 以外の文字の場合の置換文字
# @return [String] 変換後の rwx 表記
def transform_special_bit(rwx, condition, set, unset)
  if condition
    rwx[0...-1] + (rwx[-1] == 'x' ? set : unset)
  else
    rwx
  end
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

# ファイルエントリの詳細情報を列幅を揃えてマトリックスで表示する。
#
# @param file_details [Hash] 出力表示に使われる各ファイルの情報
# @param col_lengths [Hash] 出力表示の各列の長さ
def display_in_long_format(file_details, max_col_lengths)
  file_details.each do |file_detail|
    print file_detail[:type],
          file_detail[:permissions].to_s.ljust(max_col_lengths[:permissions]), ' ',
          file_detail[:nlink].to_s.rjust(max_col_lengths[:nlink]), ' ',
          file_detail[:user].to_s.ljust(max_col_lengths[:user]), ' ',
          file_detail[:group].to_s.ljust(max_col_lengths[:group]), ' ',
          file_detail[:size].to_s.rjust(max_col_lengths[:size]), ' ',
          file_detail[:mtime].to_s.ljust(max_col_lengths[:mtime]), ' ',
          file_detail[:name].to_s.ljust(max_col_lengths[:name])
    puts
  end
end

main
