class SummaryService
  def self.call(bilan)
    client = OpenAI::Client.new(access_token: ENV.fetch("OPENAI_API_KEY"))

    response = client.chat(
      parameters: {
        model: "gpt-4o-mini",
        messages: [ {
          role: "user",
          content: <<~PROMPT
            Tu es un assistant pour kinésithérapeute. Rédige un résumé en 2-3 phrases maximum du compte-rendu ci-dessous.

            Règles strictes :
            - N'utilise QUE les informations réellement présentes dans le texte.
            - Ignore complètement tout ce qui est entre crochets [ ] : ce sont des champs vides, ne les mentionne pas.
            - Si le bilan contient peu d'information, écris un résumé court et vague plutôt que de laisser des blancs.
            - Aucun champ à remplir, aucun crochet, aucune mention de données manquantes dans ta réponse.
            - Résultat directement utilisable par le kinésithérapeute, sans reformatage.

            #{bilan.content}
          PROMPT
        } ],
        temperature: 0.2
      }
    )

    response.dig("choices", 0, "message", "content")
  end
end
