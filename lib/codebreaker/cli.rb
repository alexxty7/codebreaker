module Codebreaker
  class CLI
    def initialize(game = Game.new)
      @game = game
    end

    def play
      puts 'Welcome to Codebreaker!'
      puts "Type 4 digits for a guess or 'h' for hint"
      until @game.completed?
        case answer = gets.chomp
        when /^[1-6]{4}$/
          analize_guess(answer)
        when 'h'
          puts "One of the secret code numbers is #{@game.hint}"
        else
          puts 'Wrong input'
        end
      end
    end

    def analize_guess(answer)
      result = @game.check_guess(answer)
      if @game.game_status == 'win'
        puts 'You win'
        game_over
      elsif @game.game_status == 'lose'
        puts 'You lose'
        game_over
      else
        puts result
      end
    end

    def game_over
      save_game
      play_again
    end

    def save_game
      puts 'Would you like to save your result?(yes/no)'
      return unless gets =~ /y/
      puts 'Enter your name'
      @game.save_result(gets.chomp)
    end

    def play_again
      puts 'Would you like to play again?(yes/no)'
      return unless gets =~ /y/
      @game = Game.new
      play
    end
  end
end
