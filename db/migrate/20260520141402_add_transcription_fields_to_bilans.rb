class AddTranscriptionFieldsToBilans < ActiveRecord::Migration[8.1]
  def change
    add_column :bilans, :status, :string, default: "idle"
    add_column :bilans, :raw_transcription, :text
    add_column :bilans, :manual_notes, :jsonb, default: []
    add_column :bilans, :duration_seconds, :integer, default: 0
  end
end
