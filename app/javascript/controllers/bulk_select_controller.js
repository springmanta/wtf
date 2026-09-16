import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["selectAll", "checkbox", "actions", "count"]

  connect() {
    this.refresh()
  }

  toggleAll() {
    this.checkboxTargets.forEach((checkbox) => { checkbox.checked = this.selectAllTarget.checked })
    this.refresh()
  }

  refresh() {
    const checked = this.checkboxTargets.filter((checkbox) => checkbox.checked)
    this.actionsTarget.hidden = checked.length === 0
    this.countTarget.textContent = checked.length

    if (this.hasSelectAllTarget) {
      this.selectAllTarget.checked = checked.length === this.checkboxTargets.length
      this.selectAllTarget.indeterminate = checked.length > 0 && checked.length < this.checkboxTargets.length
    }
  }
}
