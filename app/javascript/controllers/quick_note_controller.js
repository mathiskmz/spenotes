import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["view", "form", "text", "expandBtn"]

  connect() {
    if (this.hasTextTarget && this.hasExpandBtnTarget) {
      const el = this.textTarget
      // Masque "Voir plus" si le texte n'est pas réellement tronqué
      if (el.scrollHeight <= el.clientHeight + 2) {
        this.expandBtnTarget.classList.add("hidden")
      }
    }
  }

  startEdit() {
    this.viewTarget.classList.add("hidden")
    this.formTarget.classList.remove("hidden")
    this.formTarget.querySelector("textarea")?.focus()
  }

  cancelEdit() {
    this.formTarget.classList.add("hidden")
    this.viewTarget.classList.remove("hidden")
  }

  expand() {
    this.textTarget.classList.remove("line-clamp-3")
    this.expandBtnTarget.classList.add("hidden")
  }
}
