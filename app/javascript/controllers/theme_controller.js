import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["icon"]

  connect() {
    this.render(this.current())
  }

  toggle() {
    const next = this.current() === "dark" ? "light" : "dark"
    localStorage.setItem("theme", next)
    this.render(next)
  }

  current() {
    return document.documentElement.classList.contains("dark") ? "dark" : "light"
  }

  render(theme) {
    document.documentElement.classList.toggle("dark", theme === "dark")
    if (this.hasIconTarget) {
      this.iconTarget.textContent = theme === "dark" ? "☀️" : "🌙"
    }
  }
}
