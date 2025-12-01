# frozen_string_literal: true

require_relative "fcm/version"

module Fcm

  def self.run
    puts "hi"
  end

  class Error < StandardError; end
  # Your code goes here...
end

Fcm.run