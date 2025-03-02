# frozen_string_literal: true

require 'optparse'

class Option
  attr_reader :is_all, :is_reverse, :is_long

  def initialize(args)
    @is_all = false
    @is_reverse = false
    @is_long = false
    parse(args)
  end

  private

  def parse(args)
    OptionParser.new do |opt|
      opt.on('-a', 'do not ignore entries starting with .') { @is_all = true }
      opt.on('-r', 'reserse order while sorting') { @is_reverse = true }
      opt.on('-l', 'use a long listing format') { @is_long = true }
      begin
        opt.parse(args)
      rescue OptionParser::InvalidOption => e
        puts e.message
        puts opt.help
        exit 1
      end
    end
  end
end
