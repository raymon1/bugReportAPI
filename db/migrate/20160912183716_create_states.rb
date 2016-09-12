class CreateStates < ActiveRecord::Migration[5.0]
  def change
    create_table :states do |t|
      t.string :device
      t.string :os
      t.integer :memory
      t.integer :storage
      t.references :bug, index: true, foreign_key: true, null: false 

      t.timestamps
    end
  end
end
