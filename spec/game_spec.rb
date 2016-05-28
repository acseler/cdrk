require 'spec_helper'
require 'codebreaker_rack_app/game'
require 'codebreaker_rack_app/game_enums'

# Module CodebreakerRackApp
module CodebreakerRackApp
  RSpec.describe Game do
    subject(:game) { Game.new }
    context '#start' do
      before { game.start }

      it 'generates secret code' do
        expect(game.instance_variable_get(:@secret_code)).not_to be_empty
      end
      it 'saves 4 numbers secret code' do
        expect(game.instance_variable_get(:@secret_code).size).to eq 4
      end
      it 'saves secret code with numbers from 1 to 6' do
        expect(game.instance_variable_get(:@secret_code)).to match(/[1-6]+/)
      end
    end

    context '#game_over?' do
      let(:correct_pass) { game.instance_variable_get(:@secret_code) }
      let(:wrong_pass) { '3333' }
      let(:hint) { 'hint' }
      let(:hint_answer) { 'You have taken all hints.' }

      before do
        game.start
        game.instance_variable_set(:@turns, 2)
        game.instance_variable_set(:@secret_code, '1234')
      end

      it 'should return WIN' do
        expect(game.game_over?(correct_pass).values[0]).to eq GameEnums::WIN
      end

      it 'should return CONTINUE' do
        expect(game.game_over?(wrong_pass).values[0]).to eq GameEnums::CONTINUE
      end

      it 'should return LOSE' do
        game.instance_variable_set(:@turns, 1)
        expect(game.game_over?(wrong_pass).values[0]).to eq GameEnums::LOSE
      end

      it 'should return hint 3' do
        expect(game.hint_answer).to match(/[1-6]/)
      end

      context '#match_code' do
        it 'should reduce turns value by 1' do
          expect { game.send(:match_code, correct_pass) }
            .to change { game.instance_variable_get(:@turns) }.by(-1)
        end

        it 'returns ++++ if code match secret_code' do
          expect(game.send(:match_code, correct_pass)).to eq('++++')
        end
      end

      context '#check_code' do
        [
          %w(1555 +),
          %w(1255 ++),
          %w(5235 ++),
          %w(5534 ++),
          %w(1235 +++),
          %w(5234 +++),
          %w(5243 +--),
          %w(4266 +-),
          %w(3124 +---),
          %w(2134 ++--),
          %w(6645 -),
          %w(6145 --),
          %w(2543 ---),
          %w(4321 ----)
        ].each do |bank|
          it "should return #{bank[1]}" do
            expect(game.send(:check_code, bank[0])).to eq bank[1]
          end
        end
      end

      context '#success' do
        it 'should return false' do
          expect(game.send(:success, '+-+-')).to eq false
        end

        it 'should return true' do
          expect(game.send(:success, '++++')).to eq true
        end
      end

      context '#hint_answer' do
        it 'should return in 1..6' do
          expect(game.send(:hint_answer)).to match(/[1-6]/)
        end
      end
    end
  end
end
