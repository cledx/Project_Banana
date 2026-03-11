import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="week-select"
export default class extends Controller {
  generate() {
    const formData = {
            day_templates: {
              monday: { breakfast: 2, lunch: 2, dinner: 2 },
              tuesday: { breakfast: 2, lunch: 2, dinner: 2 },
              wednesday: { breakfast: 2, lunch: 2, dinner: 2 },
              thursday: { breakfast: 2, lunch: 2, dinner: 2 },
              friday: { breakfast: 2, lunch: 2, dinner: 2 },
              saturday: { breakfast: 2, lunch: 2, dinner: 2 },
              sunday: { breakfast: 2, lunch: 2, dinner: 2 }
            }
          }
          // params[:day_templates][:monday][:breakfast] = 2

          const url = `/weeks`

          fetch(url, {
            method: "POST",
            headers:{
              'Content-Type': 'application/json',
              'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
            },
            body: JSON.stringify(formData)
            }).then(response => {
              if (response.redirected) window.location.href = response.url
            })
        }
}
