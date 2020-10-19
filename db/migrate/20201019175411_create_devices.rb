class CreateDevices < ActiveRecord::Migration[6.0]
  def change
    create_table :devices do |t|
      t.text :aws_device_id, null: false
      t.string :device_name, null: false, default: ''
      t.references :user

      t.timestamps
    end

    add_index :devices, :aws_device_id, unique: true
    add_index :devices, [:aws_device_id, :user_id], unique: true
  end
end
