class AddIndexToBugs < ActiveRecord::Migration[5.0]
  def change
  	add_index :bugs, :number
  	add_index :bugs, :application_token
  end
end
