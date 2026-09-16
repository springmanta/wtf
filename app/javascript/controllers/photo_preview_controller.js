import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "image", "placeholder"]

  update() {
    const file = this.inputTarget.files[0]
    if (!file) {
      this.reset()
      return
    }

    const reader = new FileReader()
    reader.onload = () => {
      this.imageTarget.src = reader.result
      this.imageTarget.hidden = false
      this.placeholderTarget.hidden = true
    }
    reader.readAsDataURL(file)
  }

  reset() {
    this.imageTarget.hidden = true
    this.placeholderTarget.hidden = false
  }
}
