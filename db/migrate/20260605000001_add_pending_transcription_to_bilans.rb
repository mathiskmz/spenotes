class AddPendingTranscriptionToBilans < ActiveRecord::Migration[8.1]
  def change
    add_column :bilans, :pending_transcription, :text
  end
end
