class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :following
      t.string :phone
      t.string :carry
      t.string :deviceType
      t.string :searchedguest
      t.belongs_to :guest
      t.timestamps null: false
    end
  end
end
