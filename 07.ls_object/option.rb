# frozen_string_literal: true

require 'optparse'

class Option
  attr_accessor :is_all, :is_reverse, :is_long, :cli_opts

  def initialize
    @is_all = false
    @is_reverse = false
    @is_long = false
  end

  def parse(args)
    @cli_opts = OptionParser.new do |opt|
      opt.on('-a', 'do not ignore entries starting with .') { @is_all = true }
      opt.on('-r', 'reserse order while sorting') { @is_reverse = true }
      opt.on('-l', 'use a long listing format') { @is_long = true }
    end
    @cli_opts.parse(args)
  end
end
