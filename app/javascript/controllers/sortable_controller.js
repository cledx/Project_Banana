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

          fetch(`/dishes/${dish.id.split("-")[1]}`, {
            method: "PATCH",
            headers:{
              'Content-Type': 'application/json',
            },
            body: JSON.stringify({
              day_id: newDay
            })
          });
          console.log(dish);
        },
      });
    });
  }
}
