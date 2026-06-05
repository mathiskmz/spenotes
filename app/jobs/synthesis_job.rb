class SynthesisJob < ApplicationJob
  queue_as :default

  # Lance la synthèse IA après la fin de l'enregistrement
  def perform(bilan_id)
    bilan = Bilan.find(bilan_id)

    return unless bilan.status == "processing"
    return bilan.update!(status: "idle") if bilan.pending_transcription.blank? && bilan.manual_notes.blank?

    bilan.commit_transcription!
    content = SynthesisService.call(bilan)
    bilan.update!(content: content, summary: nil, recommendations: nil, status: "done")
    SummaryJob.perform_later(bilan.id)
  end
end
