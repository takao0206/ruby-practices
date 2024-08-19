#!/usr/bin/env ruby

RANGE_START = 1
RANGE_END = 20
FIZZ_NUMBER = 3
BUZZ_NUMBER = 5

numbers = RANGE_START..RANGE_END
numbers.each do |number|
  if (number % FIZZ_NUMBER).zero? && (number % BUZZ_NUMBER).zero?
    puts 'FizzBuzz'
  elsif (number % FIZZ_NUMBER).zero?
    puts 'Fizz'
  elsif (number % BUZZ_NUMBER).zero?
    puts 'Buzz'
  else
    puts number
  end
end
