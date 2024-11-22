Rails.application.routes.draw do
  root "games#index"

  resources :games
  get "/games/show_prices/:id", to: "games#show_prices", as: 'game_show_prices'
  get "/games/get_game_prices_json/:id", to: "games#get_game_prices_json", as: 'game_get_game_prices_json'
  get "/games/scrape_game_price/:id", to: "games#scrape_game_price", as: 'game_scrape_game_price'

  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
