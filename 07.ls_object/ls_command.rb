# frozen_string_literal: true

class LsCommand
  def initialize(args)
    @args = args
    @option = Option.new(args)
    @option.is_all
  end

  def run
    if @option.is_long
      display_long_list
    else
      display_short_list
    end
  end

  private

  def display_long_list
    long_list = LongList.new(is_all: @option.is_all, is_reverse: @option.is_reverse)
    puts long_list.format_total_block_kbyte
    puts long_list.format
  end

  def display_short_list
    puts ShortList.new(is_all: @option.is_all, is_reverse: @option.is_reverse).format
  end
end
