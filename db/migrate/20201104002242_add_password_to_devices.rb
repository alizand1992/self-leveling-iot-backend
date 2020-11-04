class AddPasswordToDevices < ActiveRecord::Migration[6.0]
  def change
    add_column :devices, :password, :text
  end
end
