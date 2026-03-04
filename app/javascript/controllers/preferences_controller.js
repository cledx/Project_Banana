import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["steps", "cuisines", "allergies"]

  connect() {
    this.currentPage = 0
  }

  showStep() {
    this.stepsTargets.forEach((step, index) => {
      if (this.currentPage == index) {
        step.classList.remove("d-none")
      } else {
        step.classList.add("d-none")
      }
    })
  }

  next() {
    this.currentPage += 1
    this.showStep()

    if (this.currentPage === 1) {
      document.getElementById('steps-container').classList.remove('d-none')
    }

    if (this.currentPage === 2 && !this.tomSelectInitialized) {
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

    if (this.currentPage === 3 && !this.tomSelectInitialized2) {
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

    if (this.currentPage === 5 && !this.tomSelectInitialized3) {
      new TomSelect('#disease-select', {
        plugins: ['caret_position', 'input_autogrow'],
        create: true,
        persist: false,
        placeholder: "Celiac disease, Diabetes...",
        openOnFocus: false,
        hideSelected: true,
        shouldLoad: () => false
      })
      this.tomSelectInitialized3 = true
    }
  }

  previous() {
    this.currentPage -= 1
    this.showStep()

    if (this.currentPage === 0) {
      document.getElementById('steps-container').classList.add('d-none')
    }
  }
}
