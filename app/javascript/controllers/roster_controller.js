import { Controller } from "@hotwired/stimulus"

const ZONE_TEAM = { bench: "", teamOne: "team_one", teamTwo: "team_two" }
const ZONE_ORDER = ["bench", "teamOne", "teamTwo"]

export default class extends Controller {
  static targets = [
    "card",
    "benchZone",
    "teamOneZone",
    "teamTwoZone",
    "teamOneCount",
    "teamTwoCount"
  ]

  connect() {
    this.updateCounts()
  }

  startDrag(event) {
    if (event.pointerType === "mouse" && event.button !== 0) return
    if (event.target.closest('[data-role="goal-stepper"]')) return

    const card = event.currentTarget
    event.preventDefault()

    const rect = card.getBoundingClientRect()
    this.draggingCard = card
    this.offsetX = event.clientX - rect.left
    this.offsetY = event.clientY - rect.top
    this.startZone = card.dataset.zone
    this.startWidth = rect.width
    this.moved = false

    card.setPointerCapture(event.pointerId)

    this.onMove = (e) => this.duringDrag(e)
    this.onUp = (e) => this.endDrag(e)

    card.addEventListener("pointermove", this.onMove)
    card.addEventListener("pointerup", this.onUp)
    card.addEventListener("pointercancel", this.onUp)
  }

  duringDrag(event) {
    const card = this.draggingCard
    if (!this.moved) {
      this.moved = true
      card.classList.add("shadow-xl", "scale-105")
      card.style.position = "fixed"
      card.style.zIndex = 50
      card.style.pointerEvents = "none"
      card.style.width = `${this.startWidth}px`
    }
    card.style.left = `${event.clientX - this.offsetX}px`
    card.style.top = `${event.clientY - this.offsetY}px`
  }

  endDrag(event) {
    const card = this.draggingCard
    card.removeEventListener("pointermove", this.onMove)
    card.removeEventListener("pointerup", this.onUp)
    card.removeEventListener("pointercancel", this.onUp)

    if (this.moved) {
      card.classList.remove("shadow-xl", "scale-105")
      card.style.position = ""
      card.style.left = ""
      card.style.top = ""
      card.style.zIndex = ""
      card.style.pointerEvents = ""
      card.style.width = ""

      const zone = this.zoneAt(event.clientX, event.clientY) || this.startZone
      this.moveCard(card, zone)
    } else {
      this.cycleCard(card)
    }

    this.draggingCard = null
  }

  cycleOnKey(event) {
    event.preventDefault()
    this.cycleCard(event.currentTarget)
  }

  cycleCard(card) {
    const next = ZONE_ORDER[(ZONE_ORDER.indexOf(card.dataset.zone) + 1) % ZONE_ORDER.length]
    this.moveCard(card, next)
  }

  zoneAt(x, y) {
    const el = document.elementFromPoint(x, y)
    if (!el) return null
    if (el.closest('[data-roster-target="teamOneZone"]')) return "teamOne"
    if (el.closest('[data-roster-target="teamTwoZone"]')) return "teamTwo"
    if (el.closest('[data-roster-target="benchZone"]')) return "bench"
    return null
  }

  moveCard(card, zone) {
    const target = { bench: this.benchZoneTarget, teamOne: this.teamOneZoneTarget, teamTwo: this.teamTwoZoneTarget }[zone]
    target.appendChild(card)
    card.dataset.zone = zone
    card.querySelector('[data-role="team-field"]').value = ZONE_TEAM[zone]

    const stepper = card.querySelector('[data-role="goal-stepper"]')
    stepper.hidden = zone === "bench"
    if (zone === "bench") this.setGoals(card, 0)

    this.updateCounts()
  }

  incrementGoals(event) {
    event.stopPropagation()
    const card = event.currentTarget.closest('[data-roster-target="card"]')
    this.setGoals(card, this.currentGoals(card) + 1)
  }

  decrementGoals(event) {
    event.stopPropagation()
    const card = event.currentTarget.closest('[data-roster-target="card"]')
    this.setGoals(card, Math.max(0, this.currentGoals(card) - 1))
  }

  currentGoals(card) {
    return parseInt(card.querySelector('[data-role="goals-field"]').value || "0", 10)
  }

  setGoals(card, value) {
    card.querySelector('[data-role="goals-field"]').value = value
    card.querySelector('[data-role="goals-display"]').textContent = value
  }

  updateCounts() {
    this.teamOneCountTarget.textContent = this.teamOneZoneTarget.querySelectorAll('[data-roster-target="card"]').length
    this.teamTwoCountTarget.textContent = this.teamTwoZoneTarget.querySelectorAll('[data-roster-target="card"]').length
  }
}
