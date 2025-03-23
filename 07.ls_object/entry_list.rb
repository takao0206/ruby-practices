# frozen_string_literal: true

class EntryList
  def initialize(is_all:, is_reverse:)
    @is_all = is_all
    @is_reverse = is_reverse
    @entries = []
  end

  def fetch_and_sort
    entries =
      if @is_all
        Dir.entries(Dir.pwd)
      else
        Dir.children(Dir.pwd).reject { |file| file.start_with?('.') }
      end
    entries.sort_by! { |entry| entry.dup.delete('.') }
    entries.reverse! if @is_reverse
    @entries = entries.map { |entry| Entry.new(entry) }
  end
end
