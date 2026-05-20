class Bilan < ApplicationRecord
  belongs_to :patient
  belongs_to :user

  has_many_attached :files

  # Statuts possibles du bilan d'écoute
  STATUSES = %w[idle recording paused processing done].freeze

  # Ajoute une note manuelle saisie pendant l'écoute
  def add_manual_note!(text, timestamp_seconds)
    notes = (manual_notes || []) + [ { "text" => text, "timestamp_seconds" => timestamp_seconds } ]
    update!(manual_notes: notes)
  end

  # Ajoute un segment de transcription Whisper à la suite
  def append_transcription!(segment)
    new_transcription = [ raw_transcription, segment ].compact.join(" ")
    update!(raw_transcription: new_transcription)
  end
end
