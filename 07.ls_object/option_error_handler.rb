# frozen_string_literal: true

module OptionErrorHandler
  def self.handle_error(error, flags)
    puts error.message
    puts flags.help
    exit 1
  end
end
