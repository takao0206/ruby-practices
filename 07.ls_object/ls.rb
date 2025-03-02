#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'option'
require_relative 'list'
require_relative 'entry'
require_relative 'short_list'
require_relative 'long_list'

class Ls
  def initialize(args)
    @args = args
    @option = Option.new(args)
    @option.is_all
  end

  def run
    entries = fetch_and_sort_entries
    display_list(entries)
  end

  private

  def fetch_and_sort_entries
    List.new.fetch_and_sort(@option.is_all, @option.is_reverse)
  end

  def display_list(entries)
    if @option.is_long
      display_long_list(entries)
    else
      display_short_list(entries)
    end
  end

  def display_long_list(entries)
    puts LongList.new(entries).format_total_block_kbyte
    entry_details = create_entry_details(entries)
    puts LongList.new(entry_details).format
  end

  def create_entry_details(entries)
    entries.map do |entry|
      entry_detail = Entry.new(entry)
      entry_detail.load_details
      entry_detail
    end
  end

  def display_short_list(entries)
    puts ShortList.new(entries).format
  end
end

Ls.new(ARGV).run
