class AddDataToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :followercount, :string
  	add_column :users, :profilelink, :string
  	add_column :users, :bio, :string
  	add_column :users, :website, :string
  end 
end
