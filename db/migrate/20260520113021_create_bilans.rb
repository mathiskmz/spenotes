class CreateBilans < ActiveRecord::Migration[8.1]
  def change
    create_table :bilans do |t|
      t.text :content
      t.references :patient, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
