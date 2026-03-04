import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="preferences"
export default class extends Controller {
  static targets = ["steps", "cuisines", "allergies"]
  connect() {
    this.currentPage = 0
  }

  showStep() {
    this.stepsTargets.forEach((step,index) => {
      if (this.currentPage == index) {
        step.classList.remove("d-none")
      } else {
        step.classList.add("d-none")
      }
    });
  }

  next() {
    if (this.currentPage === 0) {
      const checked = this.cuisinesTargets.filter(el => el.checked)
      if (checked.length < 1) {
        alert("Select one or more")
        return
      }
    }

    this.currentPage += 1
    this.showStep()

    if (this.currentPage === 1 && !this.tomSelectInitialized) {
      new TomSelect('#ingredients-select', {
        plugins: ['caret_position', 'input_autogrow'],
        create: true,
        persist: false,
        placeholder: "Add ingredients...",
        openOnFocus: false,
        hideSelected: true,
        shouldLoad: () => false
      })
      this.tomSelectInitialized = true
    }

    if (this.currentPage === 2 && !this.tomSelectInitialized2) {
      new TomSelect('#dislike-ingredients', {
        plugins: ['caret_position', 'input_autogrow'],
        create: true,
        persist: false,
        placeholder: "Add ingredients...",
        openOnFocus: false,
        hideSelected: true,
        shouldLoad: () => false
      })
      this.tomSelectInitialized2 = true
    }
  }

  previous() {
    this.currentPage -= 1
    this.showStep()
  }

}
