class SynthesisJob < ApplicationJob
  queue_as :default

  # Lance la synthèse IA après la fin de l'enregistrement
  def perform(bilan_id)
    bilan = Bilan.find(bilan_id)

    # On vérifie que le bilan est bien en attente de traitement
    return unless bilan.status == "processing"

    content = SynthesisService.call(bilan)
    bilan.update!(content: content, status: "done")
  end
end
