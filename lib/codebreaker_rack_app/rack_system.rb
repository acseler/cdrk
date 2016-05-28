$LOAD_PATH << File.dirname(__FILE__)
require 'erb'
require 'game'
require 'file_helper'
require 'game_enums'
require 'score'

module CodebreakerRackApp
  # Class RackSystem
  class RackSystem
    include GameEnums
    include FileHelper
    SCORE_FILE = 'codebreaker_players.yaml'

    def self.call(env)
      new(env).response.finish
    end

    def initialize(env)
      @request = Rack::Request.new(env)
    end

    def response
      path = @request.path
      if @request.get?
        get_request(path)
      elsif @request.post?
        post_request(path)
      end
    end

    private

    def render(template)
      path = File.expand_path("../../views/#{template}", __FILE__)
      ERB.new(File.read(path)).result(binding)
    end

    def get_request(path)
      case path
        when '/' then
          Rack::Response.new(render('index.html.erb'))
        when '/new_game' then
          start_game
        when '/save_score'
          save_score
        else
          Rack::Response.new('Not found', 404)
      end
    end

    def post_request(path)
      case path
        when '/hint' then
          hint
        when '/turn' then
          turn
        when '/start_game' then
          start_game
        when '/save_score' then
          save_score_request(@request.params['name'])
        else
          Rack::Response.new('Not found', 404)
      end
    end

    def start_game
      Rack::Response.new do |response|
        @request.session.clear
        @request.session[:codebreaker] = Game.new
        codebreaker.start
        response.redirect('/')
      end
    end

    def turn
      Rack::Response.new do |response|
        code = @request.params['code']
        @request.session[:result] = codebreaker.game_over?(code)
        @request.session[:code] = code
        response.redirect('/')
      end
    end

    def hint
      Rack::Response.new do |response|
        codebreaker.hint_answer
        response.redirect('/')
      end
    end

    def save_score
      if end_game
        Rack::Response.new(render('score.html.erb'))
      else
        Rack::Response.new do |response|
          response.redirect('/')
        end
      end
    end

    def codebreaker
      @request.session[:codebreaker]
    end

    def result
      @request.session[:result]
    end

    def result_success
      result[:res_success]
    end

    def score_table
      @request.session[:score_table]
    end

    def hide_save_form
      @request.session[:hide_save_form] = true
    end

    def end_game
      result ? result_success == 'win' || result_success == 'lose' : false
    end

    def code
      @request.session[:code]
    end

    def add_score_to_table(name, success, turns)
      score_table = read_players_from_file(SCORE_FILE)
      score_table << Score.new(name, success ? WIN : LOSE, turns)
      score_table = score_table.sort { |a, b| [b.success, a.turns] <=> [a.success, b.turns] }[0..9]
      write_players_to_file(score_table, SCORE_FILE)
      score_table
    end

    def save_score_request(name)
      turns = Game::TUNS_DEFAULT - codebreaker.turns
      success = codebreaker.game_success
      @request.session[:score_table] = add_score_to_table(name, success, turns)
      Rack::Response.new do |response|
        response.redirect('/save_score')
      end
    end
  end
end
