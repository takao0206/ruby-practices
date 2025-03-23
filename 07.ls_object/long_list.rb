# frozen_string_literal: true

require 'date'

class LongList
  KBYTE_PER_BLOCK = 512 / 1024.to_f
  private_constant :KBYTE_PER_BLOCK

  def initialize(entries)
    @entries = entries
  end

  def format_total_block_kbyte
    "total #{calculate_total_block_kbyte}"
  end

  def format
    max_col_lengths = calculate_max_col_lengths
    format_entry_details(max_col_lengths)
  end

  private

  def calculate_total_block_kbyte
    @entries.sum do |entry|
      calculate_entry_block_kbyte(entry.entry)
    end
  end

  def calculate_entry_block_kbyte(entry)
    file_path = File.join(Dir.pwd, entry)
    (File.lstat(file_path).blocks * KBYTE_PER_BLOCK).floor
  end

  def calculate_max_col_lengths
    max_col_lengths = {}
    keys = %i[type permissions nlink user group size mtime name]
    keys.each do |key|
      max_col_lengths[key] = @entries.map do |entry|
        entry.instance_variable_get("@#{key}").to_s.length
      end.max
    end
    max_col_lengths
  end

  def format_entry_details(max_col_lengths)
    @entries.map do |entry|
      "#{entry.type}" \
      "#{entry.permissions.to_s.ljust(max_col_lengths[:permissions])} " \
      "#{entry.nlink.to_s.rjust(max_col_lengths[:nlink])} " \
      "#{entry.user.to_s.ljust(max_col_lengths[:user])} " \
      "#{entry.group.to_s.ljust(max_col_lengths[:group])} " \
      "#{entry.size.to_s.rjust(max_col_lengths[:size])} " \
      "#{entry.mtime.to_s.ljust(max_col_lengths[:mtime])} " \
      "#{entry.name.to_s.ljust(max_col_lengths[:name])}"
    end.join("\n")
  end
end
