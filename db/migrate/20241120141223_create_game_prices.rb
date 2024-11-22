class CreateGamePrices < ActiveRecord::Migration[7.1]
  def change
    create_table :game_prices do |t|
      t.string :game_price
      t.references :game, null: false, foreign_key: true

      t.timestamps
    end
  end
end
