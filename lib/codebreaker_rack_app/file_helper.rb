require 'yaml'

module CodebreakerRackApp
  module FileHelper
    def read_players_from_file(filename)
      begin
        return Array.new unless YAML.load_file(filename)
        YAML.load_file(filename)
      rescue Errno::ENOENT => e
        e.class
      end
    end

    def write_players_to_file(players, filename)
      File.open(filename, 'w') { |file| file.write players.to_yaml }
    end
  end
end