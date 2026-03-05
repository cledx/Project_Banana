import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["count"]

  connect() {
    if (!this.hasCountTarget) return;
    this.count = parseInt(this.countTarget.innerText) || 0;
  }

  increment() {
    this.update(1)
  }

  decrement() {
    this.update(-1)
  }

  update(amount) {
    this.count += amount
    this.countTarget.innerText = this.count
  }
}
