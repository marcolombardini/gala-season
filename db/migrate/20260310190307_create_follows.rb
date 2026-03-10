class CreateFollows < ActiveRecord::Migration[8.1]
  def change
    create_table :follows, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :organization, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end

    add_index :follows, [:user_id, :organization_id], unique: true
  end
end
