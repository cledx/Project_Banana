import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "loading", "message"]

  connect() {
    this.messages = [
      "Checking cookbook...",
      "Asking Remy (the rat from Ratatouille)...",
      "Growing vegetables...",
      "Sharpening knives...",
      "Heating the oven...",
      "Tasting the sauce...",
      "Plating the dish..."
    ]
  }

  show() {
    this.contentTarget.classList.add("d-none")
    this.loadingTarget.classList.remove("d-none")

    let i = 0

    this.interval = setInterval(() => {
      this.messageTarget.textContent = this.messages[i % this.messages.length]
      i++
    }, 2500)
  }
}
