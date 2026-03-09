import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="flipcard"
export default class extends Controller {
  flip(event) {
    event.currentTarget.classList.toggle("clicked");
  }
}
