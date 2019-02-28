class CreateAppointments < ActiveRecord::Migration[5.2]
  def change
    create_table :appointments do |t|
      t.string :organizer_id
      t.string :guest_id
      t.integer :status, null: false, default: 0
      t.datetime :start_time
      t.datetime :end_time

      t.timestamps
    end

    add_index :appointments, :organizer_id
    add_index :appointments, :guest_id
    add_index :appointments, [:organizer_id, :guest_id], unique: true
  end
end
