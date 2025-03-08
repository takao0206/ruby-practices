# frozen_string_literal: true

require 'date'

class LongList < List
  KBYTE_PER_BLOCK = 512 / 1024.to_f
  private_constant :KBYTE_PER_BLOCK

  def initialize(is_all: false, is_reverse: false)
    super(is_all: is_all, is_reverse: is_reverse)
  end

  def format_total_block_kbyte
    "total #{calculate_total_block_kbyte(entries)}"
  end

  def format
    entry_details = entries.map do |entry|
      entry_detail = Entry.new(entry)
      entry_detail.load_details
      entry_detail.to_h
    end
    max_col_lengths = calculate_max_col_lengths(entry_details)
    format_entry_details(entry_details, max_col_lengths)
  end

  private

  def calculate_total_block_kbyte(entries)
    entries.sum do |entry|
      calculate_entry_block_kbyte(entry)
    end
  end

  def calculate_entry_block_kbyte(entry)
    file_path = File.join(Dir.pwd, entry)
    (File.lstat(file_path).blocks * KBYTE_PER_BLOCK).floor
  end

  def calculate_max_col_lengths(entry_details)
    max_col_lengths = {}
    entry_details.first.each_key do |key|
      max_col_lengths[key] = entry_details.map { |detail| detail[key].to_s.length }.max
    end
    max_col_lengths
  end

  def format_entry_details(entry_details, max_col_lengths)
    entry_details.map do |detail|
      "#{detail[:type]}" \
      "#{detail[:permissions].to_s.ljust(max_col_lengths[:permissions])} " \
      "#{detail[:nlink].to_s.rjust(max_col_lengths[:nlink])} " \
      "#{detail[:user].to_s.ljust(max_col_lengths[:user])} " \
      "#{detail[:group].to_s.ljust(max_col_lengths[:group])} " \
      "#{detail[:size].to_s.rjust(max_col_lengths[:size])} " \
      "#{detail[:mtime].to_s.ljust(max_col_lengths[:mtime])} " \
      "#{detail[:name].to_s.ljust(max_col_lengths[:name])}"
    end.join("\n")
  end
end
