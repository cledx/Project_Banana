import { Controller } from "@hotwired/stimulus"
import Sortable from 'sortablejs'

// Connects to data-controller="sortable"
export default class extends Controller {
  connect() {
    document.querySelectorAll(".sortable-list").forEach(el => {
      Sortable.create(el, {
        group: "calendar",
        animation: 150,
        onEnd: async function (evt) {
          const dish = evt.item.dataset.dish_id;
          const category = evt.to.dataset.category;
          const newDay = evt.to.dataset.day_id;
          const previousDay = evt.from.dataset.day_id;
          const newCategory = evt.to;
          const previousCategory = evt.from;
          console.log(previousCategory);

          const name = evt.item.dataset.recipe_name;

          if (previousDay !== document.querySelector(".today-highlight")) {
            const today = document.querySelector(`#${category}`)
            today.innerHTML = `<div id = "${previousCategory.dataset.category}">
                                <div class="card p-3 w-100 meal-card">
                                  <p class="meal-category">${previousCategory.dataset.category.charAt(0).toUpperCase() + category.slice(1)}</p>
                                  <h5 class="card-title text-secondary">No meal for ${previousCategory.dataset.category}</h5>
                                </div>
                              </div>`
          }

          if (newDay === document.querySelector(".today-highlight").id) {
            const today = document.querySelector(`#${category}`)
            today.innerHTML = `<a class="text-decoration-none" href="/dishes/${dish}">
                                <div class="card p-3 w-100 meal-card" id="${category}">
                                  <p class="meal-category">${category.charAt(0).toUpperCase() + category.slice(1)}</p>
                                  <h5 class="card-title">${name}</h5>
                                </div>
                              </a>`
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
