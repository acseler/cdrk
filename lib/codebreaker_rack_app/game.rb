$LOAD_PATH << File.dirname(__FILE__)
require 'game_enums'

module CodebreakerRackApp
  # Class Game
  class Game
    include GameEnums
    TUNS_DEFAULT = 12
    attr_reader :turns, :hint_count, :hint, :game_success

    def initialize
      @secret_code = ''
      @turns = TUNS_DEFAULT
      @hint_count = 1
      @hint = '?'
    end

    def start
      4.times { @secret_code << rand(1..6).to_s }
      @game_started = true
    end

    def game_over?(code)
      res_of_match = match_code(code)
      hash_out(if success(res_of_match)
                 WIN
               else
                 @turns == 0 ? LOSE : CONTINUE
               end, res_of_match, code)
    end

    def hint_answer
      get_hint(rand(0..3))
    end

    private

    def match_code(code)
      @turns -= 1
      return '++++' if @secret_code == code
      check_code(code)
    end

    def check_code(code)
      secret_copy = @secret_code.chars
      code_chars = code.chars
      code_match = ''

      secret_copy, code_chars = secret_copy.zip(code_chars).delete_if do |item|
        code_match << '+' if item.uniq.size == 1
      end.flatten.partition.with_index { |_item, index| index.even? }

      code_chars.each do |item|
        if secret_copy.include?(item)
          code_match << '-'
          secret_copy.delete(item)
        end
      end
      code_match
    end

    def success(code_equality)
      @game_success = code_equality == '++++'
    end

    def hash_out(res_success, res_of_match, hint = nil, code)
      {
          res_success: res_success,
          res_of_match: res_of_match,
          turns: @turns,
          code: code,
          hint: hint,
      }
    end

    def get_hint(position)
      @hint_count -= 1
      @hint = @secret_code[position]
    end
  end
end
