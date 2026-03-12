import consumer from "channels/consumer"

// Subscribe to updates for a specific day (e.g. dish regeneration on the day show page).
const element = document.querySelector("[data-day-id]")

if (element) {
  consumer.subscriptions.create(
    { channel: "DayChannel" },
    {
      received(data) {
        // data: { day_id, category, html }
        const column = document.querySelector(`[data-day-id="${data.day_id}"][data-category="${data.category}"]`)
        const target = column?.querySelector("[data-day-replaceable]")

        if (target) {
          target.innerHTML = data.html
        }
      },
    },
  )
}
