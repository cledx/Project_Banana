import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="shopping-list"
export default class extends Controller {
  static targets = ["checkboxes", "counter"]
  connect() {
    console.log("shopping list connected!");
  }

  purchased(e) {
    const formData = {shopping_item: {purchased: e.currentTarget.checked}}

    fetch(e.currentTarget.form.action, {
      method: "PATCH",
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector("meta[name='csrf-token']").content
      },
      body: JSON.stringify(formData)
    })

    e.currentTarget.parentElement.classList.toggle('text-decoration-line-through')
    e.currentTarget.parentElement.classList.toggle('text-muted')

    const remainingCount = this.checkboxesTargets.filter(checkbox=>!checkbox.checked).length

    if (remainingCount > 0) {
      this.counterTarget.innerHTML = `${remainingCount} remaining`
      this.counterTarget.classList.add("bg-warning")
      this.counterTarget.classList.remove("bg-primary")
    } else {
      this.counterTarget.innerHTML = "Done"
      this.counterTarget.classList.remove("bg-warning")
      this.counterTarget.classList.add("bg-primary")
    }
  }
}
