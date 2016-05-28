require 'spec_helper'
require 'codebreaker_rack_app/rack_system'
require 'codebreaker_rack_app/game'

# Module CodebreakerRackApp
module CodebreakerRackApp
  RSpec.describe RackSystem do
    let(:code) { { code: '1234' } }
    let(:name) { { name: 'Vasya' } }
    let(:wrong_url)  { '/wrong_url' }

    before do
      codebreaker = Game.new
      codebreaker.start
      env 'rack.session', { codebreaker: codebreaker }
      get '/'
    end

    context 'GET /' do
      it 'should allow accessing home page' do
        expect(last_response).to be_ok
      end

      it "should contain 'Welcome to Codebreaker'" do
        get '/'
        expect(last_response.body).to match(/Welcome to Codebreaker/)
      end
    end

    context 'GET /new_game' do
      it 'should puts codebreaker to session' do
        env 'rack.session', { codebreaker: nil }
        get '/new_game'
        expect(last_request.session[:codebreaker]).not_to be nil
      end
    end

    context 'GET /save_score' do

      it 'should redirect to save_score page' do
        last_request.session[:codebreaker].instance_variable_set(:@turns, 1)
        post '/turn', { code: '1111' }
        follow_redirect!
        get '/save_score'
        expect(last_response.body).to match(/placeholder="Enter your name"/)
      end

      it 'should redirect to / if game is not over' do
        post '/turn', { code: '1111' }
        follow_redirect!
        get '/save_score'
        follow_redirect!
        expect(last_response.body).to match(/action="\/turn"/)
      end
    end

    context 'GET /wrong url' do
      it "should contain 'Not found'" do
        get wrong_url
        expect(last_response.body).to match(/Not found/)
      end
    end

    context 'POST /wrong url' do
      it "should contain 'Not found'" do
        post wrong_url
        expect(last_response.body).to match(/Not found/)
      end
    end

    context 'POST /hint' do

      it 'should return digit from 1 to 6' do
        post '/hint'
        follow_redirect!
        expect(last_response.body).to match(/class="hint-answer">\n\s{16}[1-6]/)
        expect(last_request.session[:codebreaker].hint).to match(/[1-6]/)
      end
    end

    context 'POST /turn' do
      it 'should reduce turns by -1' do
        expect do
          post '/turn', { code: '1111' }
          follow_redirect!
        end.to change{ last_request.session[:codebreaker].turns }.by(-1)
      end

      it 'should hide code buttons div and show end game buttons' do
        last_request.session[:codebreaker].instance_variable_set(:@turns, 1)
        post '/turn', { code: '1111' }
        follow_redirect!
        expect(last_response.body).not_to match(/class="code-buttons"/)
        expect(last_response.body).to match(/class="end-game-buttons"/)
      end
    end

    context 'POST /start_game' do
      it 'should redirect to / and start game' do
        post '/start_game'
        follow_redirect!
        expect(last_request.env['PATH_INFO']).to eq('/')
      end
    end

    context 'POST /save_score' do
      it 'should redirect to /save_score and show score table' do
        last_request.session[:codebreaker].instance_variable_set(:@turns, 1)
        post '/turn', { code: '1111' }
        follow_redirect!
        get '/save_score'
        post '/save_score', { name: 'Vasya' }
        follow_redirect!
        expect(last_request.env['PATH_INFO']).to eq('/save_score')
        expect(last_response.body).to match(/id="score-table"/)
      end
    end
  end
end
