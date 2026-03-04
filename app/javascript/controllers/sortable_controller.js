import { Controller } from "@hotwired/stimulus"
import Sortable from 'sortablejs'

// Connects to data-controller="sortable"
export default class extends Controller {
  connect() {
    document.querySelectorAll(".sortable-list").forEach(el => {
      Sortable.create(el, {
        group: "calendar",
        animation: 150,
        onEnd: function (evt) {
          console.log(evt)
          const dish = evt.item;
          const newDay = evt.to;
          const formData = new FormData
          formData.set("dish[day_id]", newDay.id.split("-")[1])
          console.log(dish.id.split("-")[1]);

          fetch(`${location.origin}/dishes/${dish.id.split("-")[1]}`, {
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
