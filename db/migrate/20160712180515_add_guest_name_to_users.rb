class AddGuestNameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :guest_name, :string
  end
end
