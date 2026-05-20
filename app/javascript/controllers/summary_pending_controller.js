import { Controller } from "@hotwired/stimulus"

// Affiche "en cours..." pendant le délai restant, puis bascule sur le bouton de regénération
export default class extends Controller {
  static targets = ["pending", "retry"]
  static values  = { delay: Number, url: String }

  connect() {
    if (this.delayValue > 0) {
      this.timeout = setTimeout(() => this.#showRetry(), this.delayValue)
    } else {
      this.#showRetry()
    }
  }

  disconnect() {
    clearTimeout(this.timeout)
  }

  async regenerate() {
    this.retryTarget.disabled = true
    this.retryTarget.textContent = "Génération en cours…"

    await fetch(this.urlValue, {
      method: "POST",
      headers: { "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')?.content }
    })

    // Le Turbo Stream mettra à jour la frame quand le job sera terminé
    this.pendingTarget.classList.remove("hidden")
    this.retryTarget.classList.add("hidden")
  }

  #showRetry() {
    this.pendingTarget.classList.add("hidden")
    this.retryTarget.classList.remove("hidden")
  }
}
