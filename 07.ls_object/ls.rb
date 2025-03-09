#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'option'
require_relative 'entry'
require_relative 'entry_list'
require_relative 'short_list'
require_relative 'long_list'
require_relative 'ls_command'

LsCommand.new(ARGV).run
