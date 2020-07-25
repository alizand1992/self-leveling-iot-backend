# frozen_string_literal: true

class CreateNotifications < ActiveRecord::Migration[6.0]
  def change
    create_table :notifications do |t|
      t.references :user
      t.string :name, null: false
      t.text :description, null: false, default: ''

      t.timestamps
    end

    add_foreign_key :notifications, :users, on_delete: :cascade
    add_index :notifications, :name
  end
end
