require 'psych'

module Codebreaker
  class Game
    attr_reader :turns_number, :game_status, :hint_number

    TURNS_NUMBER = 5
    HINTS_NUMBER = 1

    def initialize(**options)
      @secret_code = options[:secret_code] || generate_code
      @turns_number = options[:turns_number] || TURNS_NUMBER
      @hint_number = options[:hint_number] || HINTS_NUMBER
      @game_status = options[:game_status] || ''
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

    def save_result(user_name, file = 'statistic.yml')
      result = {}
      result[:user_name] = user_name
      result[:secret_code] = @secret_code
      result[:used_attempts] = TURNS_NUMBER - @turns_number
      result[:used_hints] = HINTS_NUMBER - @hint_number
      result[:game_status] = @game_status

      File.open(file, 'a') do |f|
        f.write(Psych.dump(result))
      end
    end

    def self.load_result(file = 'statistic.yml')
      Psych.load_stream(File.read(file))
    rescue
      []
    end

    def to_h
      {
        turns_number: @turns_number,
        game_status: @game_status,
        hint_number: @hint_number,
        secret_code: @secret_code
      }
    end

    private

    def generate_code
      (1..4).map { rand(1..6) }.join
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
