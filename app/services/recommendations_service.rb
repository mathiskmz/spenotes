class RecommendationsService
  def self.call(bilan)
    client = OpenAI::Client.new(access_token: ENV.fetch("OPENAI_API_KEY"), request_timeout: 30)

    response = client.chat(
      parameters: {
        model: "gpt-4o-mini",
        messages: [ {
          role: "user",
          content: <<~PROMPT
            Tu es un assistant kinésithérapeute expert. À partir du compte-rendu ci-dessous,
            donne en 1 à 3 lignes très concises les principaux axes de prise en charge
            et 2-3 exemples d'exercices ou protocoles adaptés.

            Règles strictes :
            - Maximum ~100 mots au total.
            - Pas de champs entre crochets, pas de formules génériques.
            - Directement exploitable par le praticien, sans introduction ni conclusion.
            - Respecte EXACTEMENT ce format Markdown (ligne vide obligatoire entre le titre et la liste) :

            **Axes de travail**

            - item 1
            - item 2

            **Exemples d'exercices**

            - item 1
            - item 2

            #{bilan.content}
          PROMPT
        } ],
        temperature: 0.3
      }
    )

    text = response.dig("choices", 0, "message", "content").to_s
    ensure_list_blank_lines(text).strip
  end

  def self.ensure_list_blank_lines(text)
    # Insère une ligne vide avant chaque ligne commençant par "- " si la ligne précédente n'est pas vide
    text.gsub(/([^\n])\n(- )/, "\\1\n\n\\2")
  end
end
