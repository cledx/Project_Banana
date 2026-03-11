import { Controller } from "@hotwired/stimulus"
import Sortable from 'sortablejs'

// Connects to data-controller="sortable"
export default class extends Controller {
  // static targets = ["lists", "currentDay", ""]
  connect() {
    document.querySelectorAll(".sortable-list").forEach(el => {
      Sortable.create(el, {
        group: "calendar",
        animation: 150,
        onEnd: async function (evt) {
          const dish = evt.item.dataset.dish_id;
          const category = evt.to.dataset.category;
          const oldCategory = evt.from.dataset.category
          const newDay = evt.to.dataset.day_id;
          const previousDay = evt.from.dataset.day_id;
          const newCategory = evt.to;
          const previousCategory = evt.from;
          const currentDay = document.querySelector(".today-highlight").id
          const name = evt.item.dataset.recipe_name;

          if (newDay === currentDay) {
            const todayElement = document.querySelector(`#${category}`);

            if (todayElement) {
              todayElement.innerHTML = `
                <a class="text-decoration-none" href="/dishes/${dish}">
                  <div class="card p-3 w-100 meal-card">
                    <p class="meal-category">${category.charAt(0).toUpperCase() + category.slice(1)}</p>
                    <h5 class="card-title">${name}</h5>
                  </div>
                </a>
              `;
            } else {
              console.error(`Could not find element with id: ${category}`);
            }
            if (previousDay === currentDay) {
              document.querySelector(`#${oldCategory}`).outerHTML = `
              <div id = "${previousCategory.dataset.category}">
                <div class="card p-3 w-100 meal-card">
                  <p class="meal-category">${previousCategory.dataset.category.charAt(0).toUpperCase() + previousCategory.dataset.category.slice(1)}</p>
                  <h5 class="card-title text-secondary">No meal for ${previousCategory.dataset.category}</h5>
                </div>
              </div>
              `
            }
          } else if (previousDay === currentDay && newDay !== currentDay) {
            const today = document.querySelector(`#${oldCategory}`)

            today.outerHTML = `
            <div id = "${previousCategory.dataset.category}">
              <div class="card p-3 w-100 meal-card">
                <p class="meal-category">${previousCategory.dataset.category.charAt(0).toUpperCase() + previousCategory.dataset.category.slice(1)}</p>
                <h5 class="card-title text-secondary">No meal for ${previousCategory.dataset.category}</h5>
              </div>
            </div>
            `
          }

          if (previousCategory.children.length === 0) {
            previousCategory.innerHTML = `<div class="empty-meal">
              <span>No ${previousCategory.dataset.category} planned</span>
            </div>`
          }
          newCategory.querySelector(".empty-meal")?.remove()

          const formData = {
            dish: {day_id: newDay, category: category}
          }

          const url = `/dishes/${dish}`

          fetch(url, {
            method: "PATCH",
            headers:{
              'Content-Type': 'application/json',
              'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
            },
            body: JSON.stringify(formData)
          });
        },
      });
    });
  }
}
