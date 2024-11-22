class Game < ApplicationRecord
  extend SteamPriceScraper

  has_many :game_prices, dependent: :delete_all
  validates :title, presence: true
  validates :game_url, presence: true

  def get_game_prices
    # game_price.game_price[0..-2] - to remove currency symbol
    # gsub(',', '.') replacing colon with a dot before converting to float
    game_prices.map {|game_price| [game_price.created_at.strftime('%Y-%m-%d %T'), game_price.game_price[0..-2].gsub(',', '.').to_f]}
  end

  def self.scrape_single_game(game)
    scrape_game(game)
  end

  def self.scrape_all_games
    games = Game.all
    games.each do |game|
      scrape_game(game)
    end
  end
end
