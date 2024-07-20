#!/usr/bin/env ruby

Range_start = 1
Range_end = 20
Fizz_number = 3
Buzz_number = 5

numbers = Range_start..Range_end
numbers.each do |number|
  if (number % Fizz_number).zero? && (number % Buzz_number).zero?
    puts 'FizzBuzz'
  elsif (number % Fizz_number).zero?
    puts 'Fizz'
  elsif (number % Buzz_number).zero?
    puts 'Buzz'
  else
    puts number
  end
end
