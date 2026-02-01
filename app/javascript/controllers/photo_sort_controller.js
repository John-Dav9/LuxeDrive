import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "item", "input"]

  connect() {
    this.dragged = null
    this.refreshOrder()
    this.itemTargets.forEach((item) => this.bindItem(item))
  }

  bindItem(item) {
    item.addEventListener("dragstart", this.onDragStart)
    item.addEventListener("dragover", this.onDragOver)
    item.addEventListener("drop", this.onDrop)
    item.addEventListener("dragend", this.onDragEnd)
  }

  onDragStart = (event) => {
    this.dragged = event.currentTarget
    event.dataTransfer.effectAllowed = "move"
    event.currentTarget.classList.add("opacity-50")
  }

  onDragOver = (event) => {
    event.preventDefault()
    event.dataTransfer.dropEffect = "move"
  }

  onDrop = (event) => {
    event.preventDefault()
    if (!this.dragged) return

    const target = event.currentTarget
    if (target === this.dragged) return

    const items = Array.from(this.containerTarget.querySelectorAll("[data-photo-id]"))
    const draggedIndex = items.indexOf(this.dragged)
    const targetIndex = items.indexOf(target)

    if (draggedIndex < targetIndex) {
      target.after(this.dragged)
    } else {
      target.before(this.dragged)
    }

    this.refreshOrder()
  }

  onDragEnd = (event) => {
    event.currentTarget.classList.remove("opacity-50")
    this.dragged = null
  }

  refreshOrder() {
    const ids = Array.from(this.containerTarget.querySelectorAll("[data-photo-id]")).map(
      (item) => item.dataset.photoId
    )
    if (this.hasInputTarget) {
      this.inputTarget.value = ids.join(",")
    }
  }
}
