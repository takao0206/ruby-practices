# frozen_string_literal: true

class List
  def initialize(entries = [])
    @entries = entries
  end

  def fetch_and_sort(is_all, is_reverse)
    @entries =
      if is_all
        Dir.entries(Dir.pwd)
      else
        Dir.children(Dir.pwd).reject { |file| file.start_with?('.') }
      end
    sorted_entries = @entries.sort_by { |entry| entry.dup.delete('.') }
    is_reverse ? sorted_entries.reverse : sorted_entries
  end

  def format
    raise NotImplementedError, "#{self.class} must implement format method."
  end
end
