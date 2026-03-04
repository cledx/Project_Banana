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
          console.log(evt)
          const dish = evt.item;
          const newDay = evt.to;
          const formData = {
            dish: {day_id: newDay.id.split("-")[1]}
          }

          const url = `/dishes/${dish.id.split("-")[1]}`
          console.log(url);

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
