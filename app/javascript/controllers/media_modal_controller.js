import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "image", "video", "notification", "confirmModal", "loading", "progressBar", "progressText"]

  // --- Cycle de vie ---

  connect() {
    this._onProgress = this._onUploadProgress.bind(this)
    this._onError    = this._onUploadError.bind(this)
    this.element.addEventListener("direct-upload:progress", this._onProgress)
    this.element.addEventListener("direct-upload:error",    this._onError)
  }

  disconnect() {
    this.element.removeEventListener("direct-upload:progress", this._onProgress)
    this.element.removeEventListener("direct-upload:error",    this._onError)
  }

  // --- Lecteur média ---

  open(event) {
    const src  = event.currentTarget.dataset.src
    const type = event.currentTarget.dataset.type

    if (type === "video") {
      this.imageTarget.classList.add("hidden")
      this.videoTarget.classList.remove("hidden")
      this.videoTarget.src = src
      this.videoTarget.play()
    } else {
      this.videoTarget.classList.add("hidden")
      this.imageTarget.classList.remove("hidden")
      this.imageTarget.src = src
    }

    this.modalTarget.classList.remove("hidden")
    document.body.style.overflow = "hidden"
  }

  close() {
    this.videoTarget.pause()
    this.videoTarget.src = ""
    this.imageTarget.src = "data:,"
    this.modalTarget.classList.add("hidden")
    document.body.style.overflow = ""
  }

  closeOnBackdrop(event) {
    if (event.target === this.modalTarget) this.close()
  }

  // --- Upload validation & chargement ---

  validateAndSubmit(event) {
    const maxSize  = 100 * 1024 * 1024
    const oversized = Array.from(event.target.files).find(f => f.size > maxSize)
    if (oversized) {
      event.target.value = ""
      this.showNotification("Fichier trop volumineux. La limite est de 100 Mo par fichier.")
      return
    }
    this._showLoading()
    event.target.form.submit()
  }

  _showLoading() {
    this._setProgress(0)
    this.loadingTarget.classList.remove("hidden")
    document.body.style.overflow = "hidden"
    this._startFakeProgress()
  }

  _startFakeProgress() {
    // Simule la progression jusqu'à 90% sur ~3s, le reste disparaît au rechargement de page
    let progress = 0
    this._progressTimer = setInterval(() => {
      progress = Math.min(progress + 1, 90)
      this._setProgress(progress)
      if (progress >= 90) clearInterval(this._progressTimer)
    }, 33) // ~30 fps sur 3 secondes
  }

  _hideLoading() {
    clearInterval(this._progressTimer)
    this.loadingTarget.classList.add("hidden")
    document.body.style.overflow = ""
  }

  _setProgress(pct) {
    this.progressBarTarget.style.width = `${pct}%`
    this.progressTextTarget.textContent = `${Math.round(pct)} %`
  }

  _onUploadProgress(event) {
    // Si Cloudinary émet de vrais événements un jour, ils prennent le dessus
    clearInterval(this._progressTimer)
    this._setProgress(event.detail.progress)
  }

  _onUploadError(event) {
    event.preventDefault()
    this._hideLoading()
    this.showNotification("Erreur lors de l'envoi du fichier. Réessayez.")
  }

  // --- Notification erreur ---

  showNotification(message) {
    this.notificationTarget.textContent = message
    this.notificationTarget.classList.remove("hidden")
    clearTimeout(this._notifTimer)
    this._notifTimer = setTimeout(() => {
      this.notificationTarget.classList.add("hidden")
    }, 4000)
  }

  // --- Confirmation suppression ---

  confirmDelete(event) {
    event.preventDefault()
    this._pendingForm = event.currentTarget.closest("form")
    this.confirmModalTarget.classList.remove("hidden")
  }

  confirmDeleteSubmit() {
    if (this._pendingForm) this._pendingForm.requestSubmit()
    this.closeConfirm()
  }

  closeConfirm() {
    this.confirmModalTarget.classList.add("hidden")
    this._pendingForm = null
  }
}
