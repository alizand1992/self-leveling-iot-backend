class CreateTriggers < ActiveRecord::Migration[6.0]
  def change
    create_table :triggers do |t|
      t.string :aws_column, null: false
      t.string :relationship, null: false
      t.string :type, null: false
      t.string :value, null: false

      t.references :notification

      t.timestamps
    end

    add_index :triggers, :aws_column
  end
end
