# frozen_string_literal: true

module EntryList
  def fetch_and_sort
    @entries =
      if @is_all
        Dir.entries(Dir.pwd)
      else
        Dir.children(Dir.pwd).reject { |file| file.start_with?('.') }
      end
    @entries.sort_by! { |entry| entry.dup.delete('.') }
    @entries.reverse! if @is_reverse
    @entries
  end
end
