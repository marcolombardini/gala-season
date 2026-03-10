class CreateAttendances < ActiveRecord::Migration[8.1]
  def change
    create_table :attendances, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :event, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end

    add_index :attendances, [:user_id, :event_id], unique: true
  end
end
