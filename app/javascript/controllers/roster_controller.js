import { Controller } from "@hotwired/stimulus"

const ZONE_TEAM = { bench: "", teamOne: "team_one", teamTwo: "team_two" }
const ZONE_ORDER = ["bench", "teamOne", "teamTwo"]
const STATS = ["goals", "assists"]

const ZONE_CARD_CLASSES = {
  bench: ["bg-white/95", "dark:bg-gray-800/95"],
  teamOne: ["bg-emerald-100", "dark:bg-emerald-900/60"],
  teamTwo: ["bg-sky-100", "dark:bg-sky-900/60"]
}
const ALL_ZONE_CARD_CLASSES = Object.values(ZONE_CARD_CLASSES).flat()

const RADAR_CENTER = 150
const RADAR_RADIUS = 100
const RADAR_MAX = 10
const SKILL_COUNT = 8

function radarPolygonPoints(values) {
  return values
    .map((value, i) => {
      const angle = ((-90 + i * (360 / values.length)) * Math.PI) / 180
      const distance = RADAR_RADIUS * (value / RADAR_MAX)
      const x = RADAR_CENTER + distance * Math.cos(angle)
      const y = RADAR_CENTER + distance * Math.sin(angle)
      return `${x.toFixed(1)},${y.toFixed(1)}`
    })
    .join(" ")
}

export default class extends Controller {
  static targets = [
    "card",
    "benchZone",
    "teamOneZone",
    "teamTwoZone",
    "teamOneTopRow",
    "teamOneBottomRow",
    "teamTwoTopRow",
    "teamTwoBottomRow",
    "teamOneCount",
    "teamTwoCount",
    "teamOneRadar",
    "teamTwoRadar"
  ]

  connect() {
    this.redistributeRows("teamOne")
    this.redistributeRows("teamTwo")
    this.updateCounts()
    this.updateRadar()
    // Stable references so add/removeEventListener always agree on identity,
    // and a window-level safety net in case a card's own pointerup never fires
    // (e.g. capture lost mid-drag) — without it a card can get stuck floating.
    this.handleMove = this.handleMove.bind(this)
    this.handleUp = this.handleUp.bind(this)
    window.addEventListener("pointerup", this.handleUp)
    window.addEventListener("pointercancel", this.handleUp)
  }

  disconnect() {
    window.removeEventListener("pointerup", this.handleUp)
    window.removeEventListener("pointercancel", this.handleUp)
  }

  startDrag(event) {
    if (event.pointerType === "mouse" && event.button !== 0) return
    if (event.target.closest("[data-stat]")) return
    if (this.draggingCard) return

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
    card.addEventListener("pointermove", this.handleMove)
  }

  handleMove(event) {
    if (!this.draggingCard) return
    const card = this.draggingCard
    if (!this.moved) {
      this.moved = true
      card.classList.add("shadow-xl", "scale-105")
      card.style.position = "fixed"
      card.style.zIndex = 50
      card.style.width = `${this.startWidth}px`
    }
    card.style.left = `${event.clientX - this.offsetX}px`
    card.style.top = `${event.clientY - this.offsetY}px`
  }

  handleUp(event) {
    if (!this.draggingCard) return
    const card = this.draggingCard
    card.removeEventListener("pointermove", this.handleMove)
    if (card.hasPointerCapture && card.hasPointerCapture(event.pointerId)) {
      card.releasePointerCapture(event.pointerId)
    }

    if (this.moved) {
      card.classList.remove("shadow-xl", "scale-105")
      card.style.position = ""
      card.style.left = ""
      card.style.top = ""
      card.style.zIndex = ""
      card.style.width = ""

      const zone = this.zoneAt(event.clientX, event.clientY, card) || this.startZone
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

  zoneAt(x, y, ignoreCard) {
    const elements = document.elementsFromPoint(x, y)
    const el = elements.find((candidate) => !ignoreCard.contains(candidate))
    if (!el) return null
    if (el.closest('[data-roster-target="teamOneZone"]')) return "teamOne"
    if (el.closest('[data-roster-target="teamTwoZone"]')) return "teamTwo"
    if (el.closest('[data-roster-target="benchZone"]')) return "bench"
    return null
  }

  moveCard(card, zone) {
    if (zone === "bench") {
      this.benchZoneTarget.appendChild(card)
    } else {
      const bottomRow = zone === "teamOne" ? this.teamOneBottomRowTarget : this.teamTwoBottomRowTarget
      bottomRow.appendChild(card)
    }
    card.dataset.zone = zone
    card.querySelector('[data-role="team-field"]').value = ZONE_TEAM[zone]
    card.classList.remove(...ALL_ZONE_CARD_CLASSES)
    card.classList.add(...ZONE_CARD_CLASSES[zone])

    card.querySelectorAll('[data-role="stat-stepper"]').forEach((stepper) => {
      stepper.hidden = zone === "bench"
    })
    if (zone === "bench") STATS.forEach((stat) => this.setStat(card, stat, 0))

    this.redistributeRows("teamOne")
    this.redistributeRows("teamTwo")
    this.updateCounts()
    this.updateRadar()
  }

  // Splits a team's cards across its two rows (top row gets the smaller
  // half) instead of leaving row breaks to the browser's flex-wrap, which
  // packs as many cards as fit the container width per row rather than a
  // deliberate split.
  redistributeRows(zone) {
    const topRow = zone === "teamOne" ? this.teamOneTopRowTarget : this.teamTwoTopRowTarget
    const bottomRow = zone === "teamOne" ? this.teamOneBottomRowTarget : this.teamTwoBottomRowTarget
    const cards = [...topRow.children, ...bottomRow.children]
    const topCount = Math.floor(cards.length / 2)

    cards.forEach((card, index) => {
      const row = index < topCount ? topRow : bottomRow
      row.appendChild(card)
    })
  }

  incrementStat(event) {
    event.stopPropagation()
    const button = event.currentTarget
    const card = button.closest('[data-roster-target="card"]')
    this.setStat(card, button.dataset.stat, this.currentStat(card, button.dataset.stat) + 1)
  }

  decrementStat(event) {
    event.stopPropagation()
    const button = event.currentTarget
    const card = button.closest('[data-roster-target="card"]')
    this.setStat(card, button.dataset.stat, Math.max(0, this.currentStat(card, button.dataset.stat) - 1))
  }

  currentStat(card, stat) {
    return parseInt(card.querySelector(`[data-role="${stat}-field"]`).value || "0", 10)
  }

  setStat(card, stat, value) {
    card.querySelector(`[data-role="${stat}-field"]`).value = value
    card.querySelector(`[data-role="${stat}-display"]`).textContent = value
  }

  updateCounts() {
    this.teamOneCountTarget.textContent = this.teamOneZoneTarget.querySelectorAll('[data-roster-target="card"]').length
    this.teamTwoCountTarget.textContent = this.teamTwoZoneTarget.querySelectorAll('[data-roster-target="card"]').length
  }

  updateRadar() {
    if (!this.hasTeamOneRadarTarget) return
    this.teamOneRadarTarget.setAttribute("points", radarPolygonPoints(this.averageSkills(this.teamOneZoneTarget)))
    this.teamTwoRadarTarget.setAttribute("points", radarPolygonPoints(this.averageSkills(this.teamTwoZoneTarget)))
  }

  averageSkills(zone) {
    const cards = [...zone.querySelectorAll('[data-roster-target="card"]')]
    const sums = new Array(SKILL_COUNT).fill(0)
    if (cards.length === 0) return sums

    cards.forEach((card) => {
      JSON.parse(card.dataset.skills).forEach((value, i) => { sums[i] += value })
    })
    return sums.map((sum) => sum / cards.length)
  }
}
