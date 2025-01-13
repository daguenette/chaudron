// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

let Hooks = {}

// Sidebar hook for off-canvas menu
Hooks.Sidebar = {
  mounted() {
    const menu = document.getElementById('mobile-menu')
    const openButton = document.querySelector('button[aria-label="Open sidebar"]')
    const closeButton = document.querySelector('button[aria-label="Close sidebar"]')
    const backdrop = menu.querySelector('[aria-hidden="true"]')
    const sidebar = menu.querySelector('.flex.w-full')

    const toggleMenu = () => {
      const isHidden = menu.classList.contains('hidden')
      
      if (isHidden) {
        // Show menu
        menu.classList.remove('hidden')
        document.body.style.overflow = 'hidden'
        
        // Animate backdrop
        backdrop.classList.add('transition-opacity', 'ease-linear', 'duration-300')
        backdrop.classList.remove('opacity-0')
        backdrop.classList.add('opacity-100')
        
        // Animate sidebar
        sidebar.classList.add('transition', 'ease-in-out', 'duration-300', 'transform')
        sidebar.classList.remove('-translate-x-full')
        sidebar.classList.add('translate-x-0')
      } else {
        // Hide menu
        document.body.style.overflow = ''
        
        // Animate backdrop
        backdrop.classList.add('transition-opacity', 'ease-linear', 'duration-300')
        backdrop.classList.remove('opacity-100')
        backdrop.classList.add('opacity-0')
        
        // Animate sidebar
        sidebar.classList.add('transition', 'ease-in-out', 'duration-300', 'transform')
        sidebar.classList.remove('translate-x-0')
        sidebar.classList.add('-translate-x-full')
        
        // Wait for animations to finish before hiding
        setTimeout(() => {
          menu.classList.add('hidden')
          backdrop.classList.remove('transition-opacity', 'ease-linear', 'duration-300')
          sidebar.classList.remove('transition', 'ease-in-out', 'duration-300', 'transform')
        }, 300)
      }
    }

    // Initialize menu
    menu.classList.add('hidden')
    openButton?.addEventListener('click', toggleMenu)
    closeButton?.addEventListener('click', toggleMenu)
  }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken},
  hooks: Hooks
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

