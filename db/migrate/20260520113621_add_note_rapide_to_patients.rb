class AddNoteRapideToPatients < ActiveRecord::Migration[8.1]
  def change
    add_column :patients, :note_rapide, :text
  end
end
