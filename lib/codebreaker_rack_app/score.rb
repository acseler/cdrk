require 'json'

module CodebreakerRackApp
  # Class Score
  class Score
    attr_accessor :name, :success, :turns

    def initialize(name, success, turns)
      @name = name
      @success = success
      @turns = turns
    end

  end
end
