import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["empty", "spinner", "button", "buttonText"]

  show(event) {
    this.buttonTarget.disabled = true

    this.buttonTextTarget.textContent = "Planning..."

    this.emptyTargets.forEach((card) => {
      card.classList.add("d-none")
    })

    this.spinnerTargets.forEach((spinner) => {
      spinner.classList.remove("d-none")
    })
  }
}
