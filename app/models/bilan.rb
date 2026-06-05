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

  # Ajoute un segment de transcription Whisper à la suite (dans pending_transcription)
  def append_transcription!(segment)
    new_transcription = [ pending_transcription, segment ].compact.join(" ")
    update!(pending_transcription: new_transcription)
  end

  # Appelé au début d'une nouvelle session quand un bilan existe déjà
  def reset_session!
    update!(
      pending_transcription: nil,
      manual_notes: [],
      duration_seconds: 0,
      status: "idle"
    )
  end

  # Bascule pending_transcription → raw_transcription avant la synthèse
  def commit_transcription!
    update!(raw_transcription: pending_transcription, pending_transcription: nil)
  end
end
