class SynthesisService
  # Génère une synthèse du bilan à partir de la transcription et des notes manuelles
  # bilan : objet Bilan avec raw_transcription et manual_notes remplis
  def self.call(bilan)
    client = OpenAI::Client.new(access_token: ENV.fetch("OPENAI_API_KEY"))

    # On formate les notes manuelles pour les inclure dans le prompt
    notes_text = bilan.manual_notes.map do |note|
      minutes = note["timestamp_seconds"] / 60
      seconds = note["timestamp_seconds"] % 60
      "[#{format('%02d:%02d', minutes, seconds)}] #{note['text']}"
    end.join("\n")

    # Prompt principal envoyé à GPT
    prompt = <<~PROMPT
      Tu es un assistant pour kinésithérapeute. Rédige un compte-rendu de consultation
      clair et structuré à partir de la transcription audio et des notes manuelles ci-dessous.

      TRANSCRIPTION AUDIO :
      #{bilan.raw_transcription}

      NOTES MANUELLES DU PRATICIEN :
      #{notes_text.presence || "Aucune note manuelle"}

      Rédige un compte-rendu professionnel en français, structuré avec des sections claires.
    PROMPT

    response = client.chat(
      parameters: {
        model: "gpt-4o-mini",
        messages: [ { role: "user", content: prompt } ],
        temperature: 0.3
      }
    )

    response.dig("choices", 0, "message", "content")
  end
end
