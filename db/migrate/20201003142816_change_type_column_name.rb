class ChangeTypeColumnName < ActiveRecord::Migration[6.0]
  def change
    rename_column :triggers, :type, :trigger_type
  end
end
