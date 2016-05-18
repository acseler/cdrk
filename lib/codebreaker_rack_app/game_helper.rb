module CodebreakerRackApp
  # Module GameHelper
  module GameHelper
    def try(game, code)
      p game
      game.game_over?(code)
    end
  end
end
