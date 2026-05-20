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

    prompt = <<~PROMPT
      Tu es un assistant pour kinésithérapeute. Rédige un compte-rendu de consultation structuré
      à partir de la transcription audio et des notes manuelles ci-dessous.

      RÈGLES STRICTES — à respecter absolument :
      - N'écris QUE ce qui est présent dans la transcription ou les notes. Aucune invention.
      - INTERDIT : tout champ entre crochets comme [À compléter], [Nom], [Date], [Praticien], etc.
      - INTERDIT : toute ligne de signature, identité du praticien, coordonnées, date de consultation.
      - Si une information est absente, ne mentionne pas le champ — omets simplement la section.
      - Le compte-rendu doit être utilisable tel quel, sans rien à remplir.

      TRANSCRIPTION AUDIO :
      #{bilan.raw_transcription}

      NOTES MANUELLES DU PRATICIEN :
      #{notes_text.presence || "Aucune note manuelle"}
    PROMPT

    response = client.chat(
      parameters: {
        model: "gpt-4o-mini",
        messages: [ { role: "user", content: prompt } ],
        temperature: 0.3
      }
    )

    content = response.dig("choices", 0, "message", "content").to_s
    strip_placeholder_lines(content)
  end

  def self.strip_placeholder_lines(text)
    text
      .lines
      .reject { |line| line.match?(/\[.+\]/) }
      .join
      .gsub(/\n{3,}/, "\n\n")
      .strip
  end
end
