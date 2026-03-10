class CreateOrganizations < ActiveRecord::Migration[8.1]
  def change
    create_table :organizations, id: :uuid do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.string :website
      t.string :email, null: false
      t.string :phone
      t.string :donation_url
      t.string :primary_cause
      t.string :industries, array: true, default: []
      t.string :causes, array: true, default: []
      t.string :password_digest, null: false

      t.timestamps
    end

    add_index :organizations, :slug, unique: true
    add_index :organizations, :email, unique: true
    add_index :organizations, :industries, using: :gin
    add_index :organizations, :causes, using: :gin
  end
end
