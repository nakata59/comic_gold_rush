class CreateBooks < ActiveRecord::Migration[7.0]
  def change
    create_table :books do |t|
      t.integer :isbn, limit: 8

      t.timestamps
    end
  end
end
