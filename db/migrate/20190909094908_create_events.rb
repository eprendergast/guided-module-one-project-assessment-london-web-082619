class CreateEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :events do |t| 
      t.string :name 
      t.string :description
      t.datetime :start_time 
      t.datetime :end_time 
      t.string :location
      t.string :category
    end 
  end
end
