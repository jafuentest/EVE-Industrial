document.addEventListener('DOMContentLoaded', () => {
  $('[data-esi-id]').each((i, e) => {
    const id = e.attributes['data-esi-id'].value
    const type = e.attributes['data-esi-type'].value
    let url = 'https://esi.evetech.net/latest/universe/'

    if (type === 'item')
      url += 'types/' + id
    else if (type === 'planet')
      url += 'planets/' + id
    else if (type === 'system')
      url += 'systems/' + id

    $.ajax(url).done(data => { e.innerHTML = data.name })
  })
})
