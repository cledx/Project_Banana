import consumer from "channels/consumer"

// Subscribe to updates for a specific week.
// You need to provide the current week id from the DOM.
const element = document.querySelector("[data-week-id]")

if (element) {
  const weekId = element.dataset.weekId

  consumer.subscriptions.create(
    { channel: "WeekChannel", week_id: weekId },
    {
      received(data) {
        // data: { day_id, category, html }
        const selector = `[data-day_id="${data.day_id}"][data-category="${data.category}"]`
        const target = document.querySelector(selector)

        if (target) {
          target.innerHTML = data.html
        }
      },
    },
  )
}

