# frozen_string_literal: true

class List
  def initialize(is_all: false, is_reverse: false)
    @is_all = is_all
    @is_reverse = is_reverse
    @entries = fetch_and_sort
  end

  def format
    raise NotImplementedError, "#{self.class} must implement format method."
  end

  protected

  attr_reader :entries

  private

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
