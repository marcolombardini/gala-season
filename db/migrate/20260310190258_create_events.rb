class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events, id: :uuid do |t|
      t.references :organization, null: false, foreign_key: true, type: :uuid
      t.string :title, null: false
      t.text :description
      t.date :date, null: false
      t.time :start_time
      t.time :end_time
      t.string :venue_name
      t.string :street_address
      t.string :city
      t.string :state
      t.string :zip
      t.integer :dress_code
      t.decimal :starting_ticket_price, precision: 10, scale: 2
      t.string :ticket_link
      t.string :hashtags, array: true, default: []
      t.boolean :countdown_timer, default: false
      t.boolean :auction_items, default: false
      t.boolean :gift_items, default: false
      t.integer :status, null: false, default: 0

      t.timestamps
    end

    add_index :events, :hashtags, using: :gin
  end
end
