class CreateFollows < ActiveRecord::Migration
  def change
    create_table :follows do |t|
      t.belongs_to :user 
      t.belongs_to :user
      t.timestamps null: false
    end
  end
end
