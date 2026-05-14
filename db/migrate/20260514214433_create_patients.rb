class CreatePatients < ActiveRecord::Migration[8.1]
  def change
    create_table :patients do |t|
      t.string :name
      t.string :pathology
      t.integer :age
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
