import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "image", "video", "notification", "confirmModal"]

  // --- Lecteur média ---

  open(event) {
    const src = event.currentTarget.dataset.src
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

  // --- Upload validation ---

  validateAndSubmit(event) {
    const maxSize = 100 * 1024 * 1024
    const oversized = Array.from(event.target.files).find(f => f.size > maxSize)
    if (oversized) {
      event.target.value = ""
      this.showNotification("Fichier trop volumineux. La limite est de 100 Mo par fichier.")
      return
    }
    event.target.form.submit()
  }

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
