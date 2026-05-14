class CreateVocabularies < ActiveRecord::Migration[8.1]
  def change
    create_table :vocabularies do |t|
      t.string :input
      t.string :output
      t.string :category
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
