import { Controller } from "@hotwired/stimulus"
import portions_controller from "./portions_controller";

// Connects to data-controller="days-template"
export default class extends Controller {
  static targets = [
    "master", "portions", "breakfast", "lunch", "dinner",
    "monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"
  ];

  decrement(event) {
    const portionDisplay = event.currentTarget.closest('.d-flex').querySelector('.portion-display');
    portionDisplay.innerText = parseInt(portionDisplay.innerText) - 1;
  }

  increment(event) {
    const portionDisplay = event.currentTarget.closest('.d-flex').querySelector('.portion-display');
    portionDisplay.innerText = parseInt(portionDisplay.innerText) + 1;
  }

  decrementAll () {
    this.masterTarget.innerText = parseInt(this.masterTarget.innerText) - 1;
    this.portionsTargets.forEach(target => {
      target.innerText = parseInt(target.innerText) - 1;
    })
  }

  incrementAll () {
    this.masterTarget.innerText = parseInt(this.masterTarget.innerText) + 1;
    this.portionsTargets.forEach(target => {
      target.innerText = parseInt(target.innerText) + 1;
    })
  }

  incrementCategory(event) {
    const category = event.currentTarget.dataset.category;

    const categorySpan = event.currentTarget.closest('.d-flex').querySelector(`[data-days-template-target="${category}"]`);
    categorySpan.innerText = parseInt(categorySpan.innerText) + 1;

    const startIndex = category === "breakfast" ? 0 : category === "lunch" ? 1 : 2;
    for (let i = startIndex; i < 21; i += 3) {
      this.portionsTargets[i].innerText = parseInt(this.portionsTargets[i].innerText) + 1;
    }
  }

  decrementCategory(event) {
    const category = event.currentTarget.dataset.category;

    const categorySpan = event.currentTarget.closest('.d-flex').querySelector(`[data-days-template-target="${category}"]`);
    categorySpan.innerText = parseInt(categorySpan.innerText) - 1;

    const startIndex = category === "breakfast" ? 0 : category === "lunch" ? 1 : 2;
    for (let i = startIndex; i < 22; i += 3) {
      this.portionsTargets[i].innerText = parseInt(this.portionsTargets[i].innerText) - 1;
    }
  }

  decrementDay (event) {
    const day = event.currentTarget.dataset.day;

    if (day === "monday") {
      this.mondayTarget.innerText = parseInt(this.mondayTarget.innerText) - 1;
      this.portionsTargets.slice(0, 3).forEach (target => {
        target.innerText = parseInt(target.innerText) - 1;
      })
    } else if (day === "tuesday") {
      this.tuesdayTarget.innerText = parseInt(this.tuesdayTarget.innerText) - 1;
      this.portionsTargets.slice(3, 6).forEach (target => {
        target.innerText = parseInt(target.innerText) - 1;
      })
    } else if (day === "wednesday") {
      this.wednesdayTarget.innerText = parseInt(this.wednesdayTarget.innerText) - 1;
      this.portionsTargets.slice(6, 9).forEach (target => {
        target.innerText = parseInt(target.innerText) - 1;
      })
    } else if (day === "thursday") {
      this.thursdayTarget.innerText = parseInt(this.thursdayTarget.innerText) - 1;
      this.portionsTargets.slice(9, 12).forEach (target => {
        target.innerText = parseInt(target.innerText) - 1;
      })
    } else if (day === "friday") {
      this.fridayTarget.innerText = parseInt(this.fridayTarget.innerText) - 1;
      this.portionsTargets.slice(12, 15).forEach (target => {
        target.innerText = parseInt(target.innerText) - 1;
      })
    } else if (day === "saturday") {
      this.saturdayTarget.innerText = parseInt(this.saturdayTarget.innerText) - 1;
      this.portionsTargets.slice(15, 18).forEach (target => {
        target.innerText = parseInt(target.innerText) - 1;
      })
    } else {
      this.sundayTarget.innerText = parseInt(this.sundayTarget.innerText) - 1;
      this.portionsTargets.slice(18, 21).forEach (target => {
        target.innerText = parseInt(target.innerText) - 1;
      })
    }
  }

  incrementDay (event) {
    const day = event.currentTarget.dataset.day;

    if (day === "monday") {
      this.mondayTarget.innerText = parseInt(this.mondayTarget.innerText) + 1;
      this.portionsTargets.slice(0, 3).forEach (target => {
        target.innerText = parseInt(target.innerText) + 1;
      })
    } else if (day === "tuesday") {
      this.tuesdayTarget.innerText = parseInt(this.tuesdayTarget.innerText) + 1;
      this.portionsTargets.slice(3, 6).forEach (target => {
        target.innerText = parseInt(target.innerText) + 1;
      })
    } else if (day === "wednesday") {
      this.wednesdayTarget.innerText = parseInt(this.wednesdayTarget.innerText) + 1;
      this.portionsTargets.slice(6, 9).forEach (target => {
        target.innerText = parseInt(target.innerText) + 1;
      })
    } else if (day === "thursday") {
      this.thursdayTarget.innerText = parseInt(this.thursdayTarget.innerText) + 1;
      this.portionsTargets.slice(9, 12).forEach (target => {
        target.innerText = parseInt(target.innerText) + 1;
      })
    } else if (day === "friday") {
      this.fridayTarget.innerText = parseInt(this.fridayTarget.innerText) + 1;
      this.portionsTargets.slice(12, 15).forEach (target => {
        target.innerText = parseInt(target.innerText) + 1;
      })
    } else if (day === "saturday") {
      this.saturdayTarget.innerText = parseInt(this.lunchTarget.innerText) + 1;
      this.portionsTargets.slice(15, 18).forEach (target => {
        target.innerText = parseInt(target.innerText) + 1;
      })
    } else {
      this.sundayTarget.innerText = parseInt(this.sundayTarget.innerText) + 1;
      this.portionsTargets.slice(18, 21).forEach (target => {
        target.innerText = parseInt(target.innerText) + 1;
      })
    }
  }
}
