require 'spec_helper'

module Codebreaker
  RSpec.describe CLI do
    let(:game) { Game.new }
    let(:cli) { CLI.new(game) }

    context '#play' do
      before do
        game.instance_variable_set(:@secret_code, '1234')
        allow(cli).to receive(:gets).and_return('2234')
      end

      describe 'game not completed' do
        before { allow(cli).to receive(:game_over) }

        it 'send a welcome message' do
          expect { cli.play }.to output(/Welcome to Codebreaker/).to_stdout
        end

        it 'promts for a guess' do
          expect { cli.play }.to output(/Type 4 digits for a guess/).to_stdout
        end

        it 'return hint when user input is h' do
          allow(game).to receive(:hint).and_return('1')
          allow(cli).to receive(:gets).and_return('h', '1234')
          expect { cli.play }.to output(/secret code numbers is 1/).to_stdout
        end

        it 'return marked answer when user input is four number' do
          expect { cli.play }.to output(/\+\+\+/).to_stdout
        end

        it 'return message when user input incorrect' do
          allow(cli).to receive(:gets).and_return('232e', '1234')
          expect { cli.play }.to output(/Wrong input/).to_stdout
        end
      end

      describe 'game completed' do
        it "return 'You win' if user wins" do
          allow(cli).to receive(:game_over)
          allow(cli).to receive(:gets).and_return('1234')
          expect { cli.play }.to output(/You win/).to_stdout
        end

        it "return 'You lose' if user lose" do
          allow(cli).to receive(:game_over)
          expect { cli.play }.to output(/You lose/).to_stdout
        end

        it 'promts for save result' do
          expect { cli.play }.to output(/save your result/).to_stdout
        end

        it 'promts for play again' do
          expect { cli.play }.to output(/play again/).to_stdout
        end
      end
    end

    context '#save_game' do
      it 'proms for save result' do
        allow(cli).to receive(:gets).and_return('no')
        expect { cli.save_game }.to output(/save your result/).to_stdout
      end

      it 'promps for your name if you say yes' do
        allow(cli).to receive(:gets).and_return('yes', 'alex')
        expect { cli.save_game }.to output(/Enter your name/).to_stdout
      end

      it 'call save_result on game instance' do
        allow(cli).to receive(:puts)
        allow(cli).to receive(:gets).and_return('yes', 'alex')
        expect(game).to receive(:save_result).with('alex')
        cli.save_game
      end
    end

    context '#play_again' do
      before do
        allow(cli).to receive(:play)
        allow(cli).to receive(:gets).and_return('yes')
      end

      it 'proms for play again' do
        expect { cli.play_again }.to output(/play again/).to_stdout
      end

      it 'create new game instance' do
        allow(cli).to receive(:puts)
        expect(Game).to receive(:new)
        cli.play_again
      end

      it 'call play method' do
        allow(cli).to receive(:puts)
        expect(cli).to receive(:play)
        cli.play_again
      end
    end
  end
end
