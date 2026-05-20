class WhisperService
  # Socle de 118 termes (~199 tokens) injecté dans chaque requête Whisper.
  # Format liste de termes : Whisper s'en sert comme exemple de style/orthographe,
  # pas comme instruction. Les 25 mots restants (~224 token limit) sont réservés au vocab perso.
  KINE_BASE_PROMPT = [
    # Acronymes — priorité haute car Whisper les retranscrit souvent en toutes lettres
    "LCA, LCP, LLI, LLE, TFL, EVA, ROM, TENS, AINS, BPCO, IMC, AVP, AVC, SEP, SLA, PR, OA, BFB, MK, ETP, IRM, US, AVK, HTA, DT2,",
    # Développements des acronymes les plus prononcés à voix haute
    "LCA : ligament croisé antérieur, LCP : ligament croisé postérieur,",
    "LLI : ligament latéral interne, LLE : ligament latéral externe,",
    "TFL : tenseur du fascia lata, EVA : échelle visuelle analogique,",
    # Muscles membres inférieurs
    "gastrocnémien, soléaire, tibial antérieur, tibial postérieur, fibulaire long, fibulaire court,",
    "ilio-psoas, quadriceps, ischio-jambiers, grand fessier, moyen fessier, adducteurs, sartorius, piriforme,",
    # Muscles membres supérieurs et tronc
    "deltoïde, sus-épineux, sous-épineux, subscapulaire, biceps brachial, triceps brachial, brachioradialis, pronateur rond,",
    "érecteurs du rachis, multifidus, transverse abdominal,",
    # Os et articulations
    "patella, calcanéum, talus, scapula, acromion, coracoïde, sternum, clavicule, sacrum, ilium, pubis, ischion,",
    "fémur, tibia, fibula, humérus, radius, ulna, métatarses, phalanges,",
    "vertèbres lombaires L1 L2 L3 L4 L5, cervicales C1 C2 C3, thoraciques T1 T2,",
    # Ligaments et tendons
    "tendon d'Achille, tendon rotulien, fascia lata, bandelette ilio-tibiale,",
    # Pathologies
    "tendinopathie, épicondylite, épitrochléite, lombalgie, cervicalgie, dorsalgie, sciatique, névralgie,",
    "contracture, entorse, arthrose, hernie discale, bursite, fasciite plantaire, capsulite rétractile, luxation,",
    "syndrome canal carpien, syndrome rotulien,",
    # Mouvements et techniques
    "flexion, extension, abduction, adduction, rotation interne, rotation externe, pronation, supination, inversion, éversion,",
    "proprioception, mobilisation, renforcement musculaire, renforcement excentrique, étirements, orthèse, électrostimulation,"
  ].join(" ").freeze

  # Transcrit un chunk audio via l'API OpenAI Whisper
  # audio_data : StringIO ou File contenant le blob audio
  # vocabulary : liste des objets Vocabulary de l'utilisateur pour le prompt perso
  def self.call(audio_data, vocabulary: [])
    client = OpenAI::Client.new(access_token: ENV.fetch("OPENAI_API_KEY"))

    # On place le vocab perso en fin de prompt — Whisper utilise les derniers tokens en priorité
    vocab_perso = vocabulary.map { |v| "#{v.input}: #{v.output}" }.join(", ")
    prompt = [ KINE_BASE_PROMPT, vocab_perso ].select(&:present?).join(" ")

    # On crée un fichier temporaire car Whisper attend un vrai fichier
    Tempfile.create([ "chunk", ".webm" ]) do |tmp|
      tmp.binmode
      tmp.write(audio_data.read)
      tmp.rewind

      response = client.audio.transcribe(parameters: {
        model: "whisper-1",
        file: tmp,
        language: "fr",
        prompt: prompt
      })

      response.dig("text")
    end
  end
end
