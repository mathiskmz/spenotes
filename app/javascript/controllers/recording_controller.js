import { Controller } from "@hotwired/stimulus"

// Gère la session d'écoute : enregistrement audio, timer, notes manuelles, envoi des chunks à Whisper
export default class extends Controller {
  static targets = ["timer", "manualInput", "status", "startBtn", "pauseBtn", "resumeBtn", "stopBtn", "notesList", "confirmModal"]
  static values = {
    uploadChunkUrl: String,
    addManualNoteUrl: String,
    finalizeUrl: String
  }

  connect() {
    this.mediaRecorder   = null
    this.stream          = null
    this.elapsedSeconds  = 0
    this.timerInterval   = null
    this.isRecording     = false
    this.isPaused        = false
    this.lastUploadPromise = Promise.resolve() // pour attendre le dernier chunk avant finalize
  }

  // --- Actions publiques (appelées depuis la vue) ---

  async start() {
    try {
      this.stream = await navigator.mediaDevices.getUserMedia({ audio: true })
    } catch {
      alert("Impossible d'accéder au microphone. Vérifiez les permissions.")
      return
    }

    this.mediaRecorder = new MediaRecorder(this.stream)

    // ondataavailable se déclenche automatiquement toutes les 60s (timeslice)
    // et une dernière fois lors de l'appel à stop()
    this.mediaRecorder.ondataavailable = (e) => {
      if (e.data.size > 0) {
        this.lastUploadPromise = this._uploadChunk(e.data)
      }
    }

    // onstop est appelé après le dernier ondataavailable
    this.mediaRecorder.onstop = async () => {
      await this.lastUploadPromise // on attend que le dernier chunk soit envoyé
      await this._sendFinalize()
    }

    this.mediaRecorder.start(60000) // chunk audio toutes les 60 secondes
    this.isRecording = true
    this._startTimer()
    this._updateUI("recording")
  }

  pause() {
    if (!this.isRecording || this.isPaused) return
    this.mediaRecorder.pause()
    this.isPaused = true
    clearInterval(this.timerInterval)
    this._updateUI("paused")
  }

  resume() {
    if (!this.isPaused) return
    this.mediaRecorder.resume()
    this.isPaused = false
    this._startTimer()
    this._updateUI("recording")
  }

  // Ajoute une note manuelle — disponible que l'écoute soit active ou en pause
  async addManualNote() {
    const text = this.manualInputTarget.value.trim()
    if (!text) return

    const response = await fetch(this.addManualNoteUrlValue, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": this._csrfToken()
      },
      body: JSON.stringify({ text, timestamp_seconds: this.elapsedSeconds })
    })

    if (response.ok) {
      this._appendNoteToList(text, this.elapsedSeconds)
      this.manualInputTarget.value = ""
      this._showStatus("Note ajoutée ✓")
    }
  }

  // Soumet la note manuelle en appuyant sur Entrée (sans Shift)
  onNoteKeydown(event) {
    if (event.key === "Enter" && !event.shiftKey) {
      event.preventDefault()
      this.addManualNote()
    }
  }

  // Ouvre le modal de confirmation
  finalize() {
    this.confirmModalTarget.classList.remove("hidden")
  }

  // Appelé si l'utilisateur confirme dans le modal
  confirmFinalize() {
    this.confirmModalTarget.classList.add("hidden")
    this._updateUI("finalizing")
    this._stopAll()
    // La suite (upload dernier chunk + finalize) se passe dans mediaRecorder.onstop
  }

  // Appelé si l'utilisateur annule dans le modal
  cancelFinalize() {
    this.confirmModalTarget.classList.add("hidden")
  }

  disconnect() {
    this._stopAll()
  }

  // --- Privé ---

  async _uploadChunk(blob) {
    const formData = new FormData()
    formData.append("audio_chunk", blob, "chunk.webm")
    formData.append("chunk_duration", "60")

    await fetch(this.uploadChunkUrlValue, {
      method: "POST",
      headers: { "X-CSRF-Token": this._csrfToken() },
      body: formData
    })
  }

  async _sendFinalize() {
    this._showStatus("Génération du bilan en cours…")

    const response = await fetch(this.finalizeUrlValue, {
      method: "POST",
      headers: { "X-CSRF-Token": this._csrfToken() }
    })

    const data = await response.json()
    if (data.redirect_url) window.location.href = data.redirect_url
  }

  _startTimer() {
    this.timerInterval = setInterval(() => {
      this.elapsedSeconds++
      this._renderTimer()
      // Arrêt automatique après 1 heure
      if (this.elapsedSeconds >= 3600) this.finalize()
    }, 1000)
  }

  _stopAll() {
    clearInterval(this.timerInterval)
    if (this.mediaRecorder?.state !== "inactive") this.mediaRecorder?.stop()
    this.stream?.getTracks().forEach(t => t.stop())
    this.isRecording = false
    this.isPaused = false
  }

  _renderTimer() {
    const h = Math.floor(this.elapsedSeconds / 3600)
    const m = Math.floor((this.elapsedSeconds % 3600) / 60)
    const s = this.elapsedSeconds % 60
    this.timerTarget.textContent = [h, m, s].map(n => String(n).padStart(2, "0")).join(":")
  }

  _updateUI(state) {
    const isIdle        = state === "idle"
    const isRecording   = state === "recording"
    const isPaused      = state === "paused"
    const isFinalizing  = state === "finalizing"

    this.startBtnTarget.classList.toggle("hidden", !isIdle)
    this.pauseBtnTarget.classList.toggle("hidden", !isRecording)
    this.resumeBtnTarget.classList.toggle("hidden", !isPaused)
    this.stopBtnTarget.classList.toggle("hidden", isIdle || isFinalizing)

    this.timerTarget.classList.toggle("text-red-500", isRecording)
    this.timerTarget.classList.toggle("text-gray-400", isPaused || isFinalizing)
    this.timerTarget.classList.toggle("text-sp-primary", isIdle)

    if (isFinalizing) this._showStatus("Finalisation en cours…")
  }

  _appendNoteToList(text, timestamp) {
    if (!this.hasNotesListTarget) return

    const m = Math.floor(timestamp / 60)
    const s = timestamp % 60
    const time = `${String(m).padStart(2, "0")}:${String(s).padStart(2, "0")}`

    const item = document.createElement("div")
    item.className = "flex gap-2 text-sm text-gray-700 py-1 border-b border-gray-100"
    item.innerHTML = `<span class="text-xs text-sp-accent font-mono shrink-0 pt-0.5">${time}</span><span>${text}</span>`
    this.notesListTarget.prepend(item)
  }

  _showStatus(message) {
    if (!this.hasStatusTarget) return
    this.statusTarget.textContent = message
    setTimeout(() => { this.statusTarget.textContent = "" }, 3000)
  }

  _csrfToken() {
    return document.querySelector('meta[name="csrf-token"]')?.content
  }
}
