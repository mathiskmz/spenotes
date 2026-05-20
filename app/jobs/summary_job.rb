class SummaryJob < ApplicationJob
  queue_as :default

  def perform(bilan_id)
    bilan = Bilan.find(bilan_id)

    summary = SummaryService.call(bilan)
    bilan.update!(summary: summary)
    RecommendationsJob.perform_later(bilan.id)

    Turbo::StreamsChannel.broadcast_replace_to(
      "bilan_summary_#{bilan.patient_id}",
      target: "bilan_summary_#{bilan.patient_id}",
      partial: "patients/bilan_summary",
      locals: { bilan: bilan }
    )
  end
end
