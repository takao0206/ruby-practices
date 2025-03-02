# frozen_string_literal: true

class ShortList < List
  def initialize(is_all: false, is_reverse: false)
    super(is_all: is_all, is_reverse: is_reverse)
  end

  def format
    rows = (entries.size.to_f / COLUMNS).ceil
    list = build_list(rows, entries)
    list_to_string(list)
  end

  private

  COLUMNS = 3

  def build_list(rows, entries)
    list = create_list(rows, entries)
    format_list(list)
  end

  def create_list(rows, entries)
    list = Array.new(rows) { [] }
    entries.each_with_index do |entry, index|
      col, row = index.divmod(rows)
      list[row][col] = entry
    end
    list
  end

  def format_list(list)
    col_max_lengths = calculate_column_max_lengths(list)
    list.map do |row|
      row.map.with_index do |entry, col|
        entry ? entry.ljust(col_max_lengths[col]) : ''.ljust(col_max_lengths[col])
      end
    end
  end

  def calculate_column_max_lengths(list)
    col_max_lengths = Array.new(COLUMNS, 0)
    list.each do |row|
      row.each_with_index do |entry, col|
        col_max_lengths[col] = [col_max_lengths[col], entry.size].max if entry
      end
    end
    col_max_lengths
  end

  def list_to_string(list)
    list.map { |row| row.join('  ') }.join("\n")
  end
end
