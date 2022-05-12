// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require turbolinks

//= require jquery3
//= require popper
//= require bootstrap-sprockets
//= require bootstrap-table/bootstrap-table
//= require_tree .

document.addEventListener('turbolinks:load', function (argument) {
  $('[data-esi-id]').each(function (i, e) {
    var id = e.attributes['data-esi-id'].value
    var type = e.attributes['data-esi-type'].value
    var url = 'https://esi.evetech.net/latest/universe/'

    if (type === 'item')
      url += 'types/' + id
    else if (type === 'planet')
      url += 'planets/' + id
    else if (type === 'system')
      url += 'systems/' + id

    $.ajax(url).done(function(data) { e.innerHTML = data.name })
  })
})
