import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="slider"
export default class extends Controller {
  static targets = ["sliderValue", "display"]

  updateValue(event) {
    this.sliderValueTarget.innerText = `Family Size: ${event.target.value}`
  }

  addButton(event) {
    const mealWrapper = event.currentTarget.closest(".meal-wrapper")
    const category = event.currentTarget.dataset.category
    mealWrapper.outerHTML = `
      <div class="meal-wrapper">
        <div class="meal-section mb-3 tiny-card btn btn-primary" data-category="${category}" data-action="click->slider#deleteButton">
          <div class="meal-header-white m-0">
            <span>${category}</span>
            <span>${this.sliderValueTarget.innerText} <i class="fa-solid fa-bowl-food"></i></span>
          </div>
        </div>
      </div>
    `
  }

  deleteButton(event) {
    const mealWrapper = event.currentTarget.closest(".meal-wrapper")
    const category = event.currentTarget.dataset.category
    mealWrapper.outerHTML = `
      <div class="meal-wrapper">
        <div class="meal-section mb-3 tiny-card btn btn-outline-primary" data-category="${category}" data-action="click->slider#addButton">
          <div class="meal-header m-0">
            <span>${event.currentTarget.dataset.category}</span>
          </div>
        </div>
      </div>
    `
  }
}
