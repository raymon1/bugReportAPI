class CreateBugs < ActiveRecord::Migration[5.0]
  def change
    create_table :bugs do |t|
      t.string :application_token
      t.integer :number
      t.integer :status
      t.integer :priority
      t.text :comment

      t.timestamps
    end
  end
end
