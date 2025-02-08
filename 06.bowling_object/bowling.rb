#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'game'

def display_usage_message
  puts 'Usage: ./bowling.rb <comma-separated list of bowling scores>.'
  puts 'For example: ./bowling.rb 6,3,9,0,0,3,8,2,7,3,X,9,1,8,0,X,6,4,5'
end

if __FILE__ == $PROGRAM_NAME
  if ARGV.empty?
    display_usage_message
    exit
  end

  begin
    game = Game.new(ARGV[0])
    puts "Total Score: #{game.total_score}"
  rescue ArgumentError
    display_usage_message
    exit
  end
end
