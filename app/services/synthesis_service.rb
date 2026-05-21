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
      Tu es un masseur-kinésithérapeute expert rédigeant un Bilan Diagnostic Kinésithérapique (BDK)
      à partir d'une transcription de séance et de notes cliniques.

      RÈGLES ABSOLUES :
      - Utilise UNIQUEMENT les informations présentes dans la transcription et les notes. Zéro invention.
      - N'inclus JAMAIS de champs vides, crochets, signature, coordonnées ou date.
      - Si une section manque de données, omets-la entièrement — ne la mentionne pas.
      - Langage professionnel kinésithérapique : termes anatomiques précis, verbes d'observation clinique.
      - Chaque section rédigée doit apporter une information concrète et exploitable.

      STRUCTURE DU BDK (n'inclure que les sections documentées) :

      **Anamnèse**
      Histoire médicale, antécédents, traumatismes, chirurgies, traitements antérieurs, mode de vie.

      **Évaluation subjective**
      Plainte principale, localisation, intensité, évolution, impact fonctionnel sur les AVQ.

      **Évaluation objective**
      Résultats des tests observés : mobilité articulaire, force musculaire, posture, stabilité, tests spécifiques.

      **Diagnostic fonctionnel**
      Synthèse des déficiences identifiées : déséquilibres musculaires, restrictions articulaires, altérations posturales.

      **Objectifs et plan de traitement**
      Objectifs mesurables et techniques envisagées (manuel, exercices thérapeutiques, éducation).

      TRANSCRIPTION AUDIO :
      #{bilan.raw_transcription}

      NOTES CLINIQUES DU PRATICIEN :
      #{notes_text.presence || "Aucune note"}
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
