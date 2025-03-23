# frozen_string_literal: true

class LsCommand
  def initialize(args)
    @option = Option.new(args)
  end

  def run
    entries = EntryList.new(is_all: @option.is_all, is_reverse: @option.is_reverse).fetch_and_sort
    if @option.is_long
      long_list = LongList.new(entries)
      puts long_list.format_total_block_kbyte
      puts long_list.format
    else
      puts ShortList.new(entries).format
    end
  end
end
