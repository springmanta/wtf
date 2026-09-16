import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "image", "placeholder"]

  update() {
    const url = this.inputTarget.value.trim()
    if (url) {
      this.imageTarget.src = url
      this.imageTarget.hidden = false
      this.placeholderTarget.hidden = true
    } else {
      this.reset()
    }
  }

  handleError() {
    this.reset()
  }

  reset() {
    this.imageTarget.hidden = true
    this.placeholderTarget.hidden = false
  }
}
