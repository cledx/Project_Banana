import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="favorites"
export default class extends Controller {
  static targets = ["btns"]
  connect() {
  }

  async toggle(e) {
    const recipeId = e.currentTarget.dataset.recipeId
    await fetch(`/favorites/toggle?recipe_id=${recipeId}`)

    this.btnsTargets.forEach(btn => {
      if (btn.dataset.recipeId == recipeId) {
        btn.querySelector("i").classList.toggle("fa-solid")
        btn.querySelector("i").classList.toggle("fa-regular")
      }
    });
  }

  delete(e) {
    const recipeId = e.currentTarget.dataset.recipeId
    fetch(`/favorites/toggle?recipe_id=${recipeId}`)
    this.element.remove()
  }
}
