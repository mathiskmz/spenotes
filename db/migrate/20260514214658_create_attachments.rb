class CreateAttachments < ActiveRecord::Migration[8.1]
  def change
    create_table :attachments do |t|
      t.string :file_url
      t.string :file_type
      t.integer :file_size
      t.references :note, null: false, foreign_key: true

      t.timestamps
    end
  end
end
