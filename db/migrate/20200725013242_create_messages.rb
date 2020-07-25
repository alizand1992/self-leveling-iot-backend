# frozen_string_literal: true

class CreateMessages < ActiveRecord::Migration[6.0]
  def change
    create_table :messages do |t|
      t.references :notification
      t.text :text, null: false
      t.integer :status, null: false

      t.timestamps
    end

    add_foreign_key :messages, :notifications, on_delete: :cascade
    add_index :messages, :status
  end
end
