import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select", "teamOneCount", "teamTwoCount"]

  connect() {
    this.recount()
  }

  recount() {
    let teamOne = 0
    let teamTwo = 0

    this.selectTargets.forEach((select) => {
      if (select.value === "team_one") teamOne++
      if (select.value === "team_two") teamTwo++
    })

    this.teamOneCountTarget.textContent = teamOne
    this.teamTwoCountTarget.textContent = teamTwo
  }
}
