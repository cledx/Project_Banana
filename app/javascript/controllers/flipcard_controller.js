import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="flipcard"
export default class extends Controller {
  flip(event) {
    if (event.target.closest('a') ||
        event.target.closest('.delete-dish-btn') ||
        event.target.closest('i')) {
      return;
    }
    event.currentTarget.classList.toggle("clicked");
  }
}
