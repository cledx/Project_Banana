import { Controller } from "@hotwired/stimulus"
import Swal from 'sweetalert2'

export default class extends Controller {
  static targets = ["content", "loading", "message"]

  connect() {
    this.messages = [
      "Checking cookbook...",
      "Asking Remy (the rat from Ratatouille)...",
      "Growing vegetables...",
      "Sharpening knives...",
      "Heating the oven...",
      "Tasting the sauce...",
      "Plating the dish..."
    ]
  }

  show() {
    this.contentTarget.classList.add("d-none")
    this.loadingTarget.classList.remove("d-none")

    let i = 0

    this.interval = setInterval(() => {
      this.messageTarget.textContent = this.messages[i % this.messages.length]
      i++
    }, 2500)
  }

    trigger(e) {
    e.preventDefault()
    const action = e.currentTarget.href
    const swalWithBootstrapButtons = Swal.mixin({
      customClass: {
        confirmButton: "btn btn-success",
        cancelButton: "btn btn-danger m-2"
      },
      buttonsStyling: false
    });
    swalWithBootstrapButtons.fire({
      title: "Do you want new recipe?",
      text: "We will regenarate a new dish to you.",
      icon: "question",
      showCancelButton: true,
      confirmButtonText: "Change Recipe",
      cancelButtonText: "No, cancel",
      reverseButtons: true
    }).then((result) => {
      if (result.isConfirmed) {
        // regenerating dish
        fetch(action, {
          method: "PATCH",
           headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': document.querySelector("meta[name='csrf-token']").content
          }
        })
        // show loading
        this.show()

        swalWithBootstrapButtons.fire({
          title: "Changed!",
          text: "Your dish has been changed.",
          icon: "success"
        });
      } else if (
        /* Read more about handling dismissals below */
        result.dismiss === Swal.DismissReason.cancel
      ) {
        swalWithBootstrapButtons.fire({
          title: "Cancelled",
          icon: "error"
        });
      }
    });
  }
}
