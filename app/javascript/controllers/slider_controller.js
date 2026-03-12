import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="slider"
export default class extends Controller {
  static targets = ["sliderValue", "display", "value"]

  updateValue(event) {
    this.sliderValueTarget.innerText = `Portions: `
  }

  addButton(event) {
    const mealWrapper = event.currentTarget.closest(".meal-wrapper")
    const category = event.currentTarget.dataset.category
    const day = event.currentTarget.dataset.day
    mealWrapper.outerHTML = `
      <div class="meal-wrapper">
        <div class="meal-section mb-3 tiny-card btn btn-primary" data-category="${category}" data-day="${day}" data-action="click->slider#deleteButton">
          <div class="meal-header-white m-0">
            <span>${category}</span>
            <span>Portions: <i class="fa-solid fa-bowl-food"></i></span>
          </div>
        </div>
      </div>
    `
  }

  deleteButton(event) {
    const mealWrapper = event.currentTarget.closest(".meal-wrapper")
    const category = event.currentTarget.dataset.category
    const day = event.currentTarget.dataset.day
    mealWrapper.outerHTML = `
      <div class="meal-wrapper">
        <div class="meal-section mb-3 tiny-card btn btn-outline-primary" data-category="${category}" data-day="${day}" data-action="click->slider#addButton">
          <div class="meal-header m-0">
            <span>${event.currentTarget.dataset.category}</span>
          </div>
        </div>
      </div>
    `
  }

  generate() {
    console.log("clicked");

    const familySize = parseInt(this.valueTarget.value);
    const days = ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"];
    const dayTemplates = {};

    days.forEach((day, index) => {
      dayTemplates[day] = {};
      const meals = ["breakfast", "lunch", "dinner"]

      meals.forEach(meal => {
        const capitalizedMeal = meal.charAt(0).toUpperCase() + meal.slice(1);
        const mealSection = document.querySelector(`[data-day="${day}"][data-category="${capitalizedMeal}"]`);
        console.log(`Looking for [data-day="${day}"][data-category="${meal}"]`, mealSection);

        if (mealSection) {
          const isAdded = mealSection.classList.contains("btn-primary");
          console.log(`${day} ${meal} - isAdded:`, isAdded, "classes:", mealSection.className);
          dayTemplates[day][meal] = isAdded ? familySize : 0;
        } else {
          dayTemplates[day][meal] = 0
        }
      })
    })

    const formData = { day_templates: dayTemplates }
    console.log(formData);
    const url = `/weeks`

    fetch(url, {
      method: "POST",
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify(formData)
    }).then(response => {
      if (response.redirected) window.location.href = response.url
    })
  }
}
