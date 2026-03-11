import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["empty", "load", "button", "buttonText"]

  show(event) {
    this.loadTarget.classList.remove("d-none")

    this.buttonTarget.disabled = true
    this.buttonTextTarget.textContent = "Planning..."

    this.emptyTargets.forEach((card) => {
      card.classList.add("d-none")
    })
  }
}
