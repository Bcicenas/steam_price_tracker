class GamesController < ApplicationController
  before_action :find_game, only: [:edit, :update, :destroy, :show_prices, :get_game_prices_json, :scrape_game_price]

  def index
    @games = Game.all
  end

  def new
    @game = Game.new
  end

  def show_prices
  end

  def get_game_prices_json
    render json: @game.get_game_prices
  end

  def edit
  end

  def update
    @game.assign_attributes(game_params)

    if @game.save
      redirect_to root_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def create
    @game = Game.new(game_params)

    if @game.save
      redirect_to root_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def scrape_game_price
    Game.scrape_single_game(@game)
  end

  def destroy
    if @game.destroy
      redirect_to root_path
    else
      render :new, status: :unprocessable_entity
    end 
  end

  private

  def game_params
    params.require(:game).permit(:title, :game_url)
  end

  def find_game
    @game = Game.find(params[:id])
  end
end
