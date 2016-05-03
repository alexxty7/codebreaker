require 'psych'

module Codebreaker
  class Game
    attr_reader :turns_number, :game_status, :hint_number

    TURNS_NUMBER = 5
    HINTS_NUMBER = 1

    def initialize
      @secret_code = generate_code
      @turns_number = TURNS_NUMBER
      @hint_number = HINTS_NUMBER
      @game_status = ''
    end

    def check_guess(answer)
      @turns_number -= 1
      result = mark_guess(answer)
      if result == '++++'
        @game_status = 'win'
      elsif @turns_number <= 0
        @game_status = 'lose'
      end
      result
    end

    def hint
      return "You don't have hint" if @hint_number == 0
      @hint_number -= 1
      @secret_code[rand(4)]
    end

    def completed?
      !@game_status.empty?
    end

    def save_result(user_name)
      result = {}
      result[:user_name] = user_name
      result[:secret_code] = @secret_code
      result[:used_attempts] = TURNS_NUMBER - @turns_number
      result[:used_hints] = HINTS_NUMBER - @hint_number
      result[:game_status] = @game_status

      File.open('statistic.yml', 'a') do |f|
        f.write(Psych.dump(result))
      end
    end

    def self.load_result
      begin
        Psych.load_stream(File.read('statistic.yml'))
      rescue
        []
      end
    end

    private

    def generate_code
      (1..4).map { rand(1..6).to_s }.join
    end

    def mark_guess(answer)
      result = ''
      code_chars = @secret_code.chars

      answer.chars.each_with_index do |n, i|
        next unless n == code_chars[i]
        result << '+'
        code_chars[i] = ''
      end

      answer.chars.each do |ans|
        next unless code_chars.include?(ans)
        result << '-'
        code_chars.delete_at(code_chars.index(ans))
      end

      result
    end
  end
end
