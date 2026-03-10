class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users, id: :uuid do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false
      t.string :username, null: false
      t.text :bio
      t.boolean :visibility, default: true
      t.boolean :visibility_full_name, default: true
      t.boolean :visibility_email, default: false
      t.string :state
      t.string :city
      t.date :birthdate
      t.string :sex
      t.string :social_x
      t.string :social_linkedin
      t.string :social_instagram
      t.string :social_facebook
      t.string :interested_causes, array: true, default: []
      t.string :interested_industries, array: true, default: []
      t.string :password_digest, null: false

      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, :username, unique: true
    add_index :users, :interested_causes, using: :gin
    add_index :users, :interested_industries, using: :gin
  end
end
