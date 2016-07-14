class CreateGuests < ActiveRecord::Migration
  def change
    create_table :guests do |t|
		t.string :provider
		t.string :uid
		t.string :guestname
		t.string :token
		t.string :secret
	  	t.timestamps null: false
	end
  end
end
