import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="preferences"
export default class extends Controller {
  static targets = ["steps", "cuisines"]
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
      if (checked.length < 1 || checked.length > 3) {
        alert("Please select up to 3 cuisines.")
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

  limitCuisines() {
    const checked = this.cuisinesTargets.filter(el => el.checked)
    this.cuisinesTargets.forEach(el => {
      if (!el.checked) {
        el.disabled = checked.length >= 3
      }
    })
  }

  previous() {
    this.currentPage -= 1
    this.showStep()
  }

}
