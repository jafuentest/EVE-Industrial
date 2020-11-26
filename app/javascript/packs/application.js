// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import 'popper.js'
import 'bootstrap'
import 'bootstrap-table'

require("@rails/ujs").start()
require("turbolinks").start()


// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)

document.addEventListener("turbolinks:load", () => {
  $("[data-esi-id]").each((i, e) => {
    const id = e.attributes['data-esi-id'].value
    const type = e.attributes['data-esi-type'].value
    let url = 'https://esi.evetech.net/latest/universe/'

    if (type === "item")
      url += "types/" + id
    else if (type === "planet")
      url += "planets/" + id
    else if (type === "system")
      url += "systems/" + id

    $.ajax(url).done(data => { e.innerHTML = data.name })
  })
})
