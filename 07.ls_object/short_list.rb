# frozen_string_literal: true

class ShortList < List
  def initialize(is_all: false, is_reverse: false)
    super(is_all: is_all, is_reverse: is_reverse)
  end

  def format
    rows = (entries.size.to_f / COLUMNS).ceil
    list = build_list(rows, entries, calculate_max_name_length(entries))
    list_to_string(list)
  end

  private

  COLUMNS = 3

  def calculate_max_name_length(entries)
    entries.map(&:length).max
  end

  def build_list(rows, entries, max_entry_length)
    list = Array.new(rows) { [] }
    entries.each_with_index do |entry, index|
      col, row = index.divmod(rows)
      list[row][col] = entry.ljust(max_entry_length)
    end
    list
  end

  def list_to_string(list)
    list.map { |row| row.join(' ') }.join("\n")
  end
end
