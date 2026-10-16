// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "bootstrap"

const setupTableSearch = () => {
	const searchInput = document.querySelector("[data-table-search]")
	const table = document.querySelector(".data-table")

	if (!searchInput || !table) return

	searchInput.value = ""
	searchInput.addEventListener("input", () => {
		const query = searchInput.value.trim().toLowerCase()

		table.querySelectorAll("tbody tr").forEach((row) => {
			row.hidden = query.length > 0 && !row.textContent.toLowerCase().includes(query)
		})
	})
}

document.addEventListener("turbo:load", setupTableSearch)

const setupNotifications = () => {
	const menu = document.querySelector("[data-notification-menu]")
	if (!menu || menu.dataset.ready) return

	const toggle = menu.querySelector("[data-notification-toggle]")
	const panel = menu.querySelector("[data-notification-panel]")
	const clear = menu.querySelector("[data-notification-clear]")
	const dot = menu.querySelector("[data-notification-dot]")
	const items = [...menu.querySelectorAll(".notification-item")]
	const empty = menu.querySelector("[data-notification-empty]")

	const close = () => {
		panel.hidden = true
		toggle.setAttribute("aria-expanded", "false")
	}

	toggle.addEventListener("click", (event) => {
		event.stopPropagation()
		const isOpen = !panel.hidden
		panel.hidden = isOpen
		toggle.setAttribute("aria-expanded", String(!isOpen))
	})
	panel.addEventListener("click", (event) => event.stopPropagation())
	clear.addEventListener("click", () => {
		items.forEach((item) => { item.hidden = true })
		empty.hidden = false
		dot.hidden = true
	})
	document.addEventListener("click", close)
	document.addEventListener("keydown", (event) => {
		if (event.key === "Escape") close()
	})
	menu.dataset.ready = "true"
}

document.addEventListener("turbo:load", setupNotifications)

const setupProfile = () => {
	const menu = document.querySelector("[data-profile-menu]")
	if (!menu || menu.dataset.ready) return

	const toggle = menu.querySelector("[data-profile-toggle]")
	const panel = menu.querySelector("[data-profile-panel]")
	const name = menu.querySelector("[data-profile-name]")
	const avatar = menu.querySelector("[data-profile-avatar]")
	const nameInput = menu.querySelector("[data-profile-name-input]")
	const avatarInput = menu.querySelector("[data-profile-avatar-input]")
	const save = menu.querySelector("[data-profile-save]")
	const colors = menu.querySelectorAll("[data-profile-color]")
	const avatarChoices = menu.querySelectorAll("[data-profile-avatar-choice]")

	const saved = JSON.parse(localStorage.getItem("todo-admin-profile") || "{}")
	const applyProfile = (profile) => {
		name.textContent = profile.name || "Admin User"
		avatar.textContent = profile.avatar || "A"
		avatar.style.background = profile.color || "linear-gradient(135deg, #fddd8d, #d78d4d)"
	}
	applyProfile(saved)

	const close = () => {
		panel.hidden = true
		toggle.setAttribute("aria-expanded", "false")
	}
	toggle.addEventListener("click", (event) => {
		event.stopPropagation()
		panel.hidden = !panel.hidden
		toggle.setAttribute("aria-expanded", String(!panel.hidden))
		if (!panel.hidden) {
			nameInput.value = name.textContent
			avatarInput.value = avatar.textContent
		}
	})
	panel.addEventListener("click", (event) => event.stopPropagation())
	colors.forEach((colorButton) => colorButton.addEventListener("click", () => {
		avatarInput.dataset.color = colorButton.dataset.profileColor
	}))
	avatarChoices.forEach((avatarChoice) => avatarChoice.addEventListener("click", () => {
		avatarInput.value = avatarChoice.dataset.profileAvatar
	}))
	save.addEventListener("click", () => {
		const profile = {
			name: nameInput.value.trim() || "Admin User",
			avatar: avatarInput.value.trim().slice(0, 2) || "A",
			color: avatarInput.dataset.color || saved.color
		}
		localStorage.setItem("todo-admin-profile", JSON.stringify(profile))
		applyProfile(profile)
		close()
	})
	document.addEventListener("click", close)
	document.addEventListener("keydown", (event) => {
		if (event.key === "Escape") close()
	})
	menu.dataset.ready = "true"
}

document.addEventListener("turbo:load", setupProfile)

document.addEventListener("turbo:load", () => {
	const modal = document.querySelector("[data-confirm-modal]")
	if (!modal || modal.dataset.ready) return

	const message = modal.querySelector("[data-confirm-message]")
	const submit = modal.querySelector("[data-confirm-submit]")
	let resolveConfirmation

	const close = (confirmed) => {
		modal.hidden = true
		document.body.classList.remove("modal-open")
		resolveConfirmation?.(confirmed)
		resolveConfirmation = null
	}

	modal.querySelectorAll("[data-confirm-cancel]").forEach((button) => {
		button.addEventListener("click", () => close(false))
	})
	submit.addEventListener("click", () => close(true))
	modal.dataset.ready = "true"

	Turbo.config.forms.confirm = (text) => new Promise((resolve) => {
		message.textContent = text
		resolveConfirmation = resolve
		modal.hidden = false
		document.body.classList.add("modal-open")
		submit.focus()
	})
})
