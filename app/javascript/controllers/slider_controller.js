import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["output"]

  update(event) {
    this.outputTarget.textContent = event.target.value
  }
}
