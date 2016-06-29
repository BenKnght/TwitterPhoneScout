class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.text :name
      t.text :following
      t.text :phone
      t.text :carry
      t.text :deviceType
      #t.timestamps null: false
    end
  end
end
