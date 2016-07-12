class CreateGuests < ActiveRecord::Migration
  def change
    #drop_table :users
    create_table :guests do |t|
      t.string :provider
      t.string :uid
      t.string :guest_name
      t.string :token
      t.string :secret

      t.timestamps null: false
    end
  end
end
