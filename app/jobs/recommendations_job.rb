class RecommendationsJob < ApplicationJob
  queue_as :default

  def perform(bilan_id)
    bilan = Bilan.find(bilan_id)

    recommendations = RecommendationsService.call(bilan)
    bilan.update!(recommendations: recommendations)

    Turbo::StreamsChannel.broadcast_replace_to(
      "bilan_recommendations_#{bilan.patient_id}",
      target: "bilan_recommendations_#{bilan.patient_id}",
      partial: "patients/bilan_recommendations",
      locals: { bilan: bilan }
    )
  end
end
