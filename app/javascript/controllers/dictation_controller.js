import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["textarea", "status", "micButton", "fileInput"]

  connect() {
    this.recognition = null
    this.isListening  = false
    this.supported    = "webkitSpeechRecognition" in window || "SpeechRecognition" in window
  }

  // --- Dictée Web Speech API ---

  toggleDictation() {
    if (!this.supported) {
      alert("La dictée vocale n'est pas supportée par ce navigateur. Essayez Chrome ou Safari.")
      return
    }
    this.isListening ? this._stopDictation() : this._startDictation()
  }

  _startDictation() {
    const SR = window.SpeechRecognition || window.webkitSpeechRecognition
    this.recognition = new SR()
    this.recognition.lang = "fr-FR"
    this.recognition.continuous = true
    this.recognition.interimResults = true

    this.recognition.onresult = (event) => {
      let interim = ""
      for (let i = event.resultIndex; i < event.results.length; i++) {
        const t = event.results[i][0].transcript
        if (event.results[i].isFinal) {
          this.textareaTarget.value += t + " "
        } else {
          interim = t
        }
      }
      if (this.hasStatusTarget) this.statusTarget.textContent = interim
    }

    this.recognition.onerror = () => this._stopDictation()
    // relance automatique si le navigateur coupe (iOS)
    this.recognition.onend = () => {
      if (this.isListening) this.recognition.start()
    }

    this.recognition.start()
    this.isListening = true
    if (this.hasMicButtonTarget) {
      this.micButtonTarget.classList.add("text-red-500")
      this.micButtonTarget.classList.remove("text-gray-400")
    }
    if (this.hasStatusTarget) this.statusTarget.textContent = "En écoute…"
  }

  _stopDictation() {
    this.recognition?.stop()
    this.isListening = false
    if (this.hasMicButtonTarget) {
      this.micButtonTarget.classList.remove("text-red-500")
      this.micButtonTarget.classList.add("text-gray-400")
    }
    if (this.hasStatusTarget) this.statusTarget.textContent = ""
  }

  // --- Pièces jointes ---

  openFilePicker() {
    if (this.hasFileInputTarget) this.fileInputTarget.click()
  }

  validateAndUpload(event) {
    const maxSize  = 100 * 1024 * 1024
    const oversized = Array.from(event.target.files).find(f => f.size > maxSize)
    if (oversized) {
      event.target.value = ""
      alert("Fichier trop volumineux. La limite est de 100 Mo.")
      return
    }
    event.target.form.submit()
  }

  disconnect() {
    this._stopDictation()
  }
}
