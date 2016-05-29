require 'spec_helper'

module Codebreaker
  RSpec.describe Game do
    let(:game) { Game.new }

    describe '#initialize' do
      it 'generates secret code' do
        expect(game.instance_variable_get(:@secret_code)).not_to be_empty
      end

      it 'saves 4 numbers secret code' do
        expect(game.instance_variable_get(:@secret_code).size).to eq(4)
      end

      it 'saves secret code with numbers from 1 to 6' do
        expect(game.instance_variable_get(:@secret_code)).to match(/[1-6]+/)
      end
    end

    describe '#mark_guess' do
      before do
        allow_any_instance_of(Game).to receive(:generate_code).and_return('1234')
      end

      it 'mark right guess with +' do
        expect(game.send(:mark_guess, '1234')).to eq('++++')
      end

      it 'mark right guess with different position with -' do
        expect(game.send(:mark_guess, '4321')).to eq('----')
      end

      [
        ['1134', '1155', '++'], ['1134', '5115', '+-'], ['1134', '5511', '--'],
        ['1134', '1115', '++'], ['1134', '5111', '+-'], ['1234', '1555', '+'],
        ['1234', '2555', '-'], ['1234', '5224', '++'], ['1234', '5154', '+-'],
        ['1234', '2545', '--'], ['1234', '5234', '+++'], ['1234', '5134', '++-'],
        ['1234', '5124', '+--'], ['1234', '5115', '-']
      ].each do |el|
        it "when code is #{el[0]} and guess is #{el[1]} should return #{el[2]}" do
          game.instance_variable_set(:@secret_code, el[0])
          expect(game.send(:mark_guess, el[1])).to eq(el[2])
        end
      end
    end

    describe '#generate_code' do
      it 'return 4 numbers from 1 to 6' do
        expect(game.send(:generate_code)).to match(/[1-6]{4}/)
      end

      it 'return different numbers each times' do
        expect(game.send(:generate_code)).to_not eq(game.send(:generate_code))
      end
    end

    describe '#check_guess' do
      before do
        allow_any_instance_of(Game).to receive(:generate_code).and_return('1234')
      end

      it 'decrease turn number by 1' do
        expect { game.check_guess('1234') }.to change { game.turns_number }.by(-1)
      end

      it 'set game status to win if a guess exactly matches the secret code' do
        game.check_guess('1234')
        expect(game.game_status).to eq('win')
      end

      it 'set game status to lose if turns is out' do
        game.instance_variable_set(:@turns_number, 0)
        game.check_guess('4321')
        expect(game.game_status).to eq('lose')
      end

      it 'return marked result' do
        expect(game.check_guess('1234')).to eq('++++')
      end
    end

    describe '#hint' do
      it 'reveals one of the numbers in the secret code' do
        expect(game.instance_variable_get(:@secret_code)).to include(game.hint)
      end

      it 'descrease hint number by 1' do
        expect { game.hint }.to change { game.hint_number }.by(-1)
      end

      it 'return warning message if hint_number = 0' do
        game.hint
        expect(game.hint).to eq("You don't have hint")
      end
    end

    describe '#save result' do
      after do
        File.delete('statistic.yml')
      end

      it 'save result to file' do
        game.save_result('alex')
        expect(File.exist?('statistic.yml')).to eq true
      end
    end

    describe '.load_result' do
      it 'loads saved result' do
        game.save_result('alex')
        result = Game.load_result
        expect(result[0][:user_name]).to eq('alex')
        File.delete('statistic.yml')
      end

      it 'retun empty array if file dont exist' do
        expect(Game.load_result).to eq([])
      end
    end

    describe '#to_h' do
      it 'saves game condition in hash' do
        game.instance_variable_set(:@secret_code, '1234')
        expect(game.to_h).to eq(
          turns_number: 5,
          game_status: '',
          hint_number: 1,
          secret_code: '1234'
        )
      end
    end

    describe 'build from hash' do
      it 'retuns game instance with condition from hash' do
        hash = {
          turns_number: 10,
          game_status: '',
          hint_number: 1,
          secret_code: '1234'
        }
        expect(Game.new(hash).turns_number).to eq(10)
      end
    end
  end
end
