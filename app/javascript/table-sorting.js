window.priceSorter = function(a, b) {
  var aa = parseFloat(a.replaceAll(',', ''))
  var bb = parseFloat(b.replaceAll(',', ''))

  return aa - bb
}

window.nameSorter = function(a, b) {
  return a.replace(/\d+/,'').localeCompare(b.replace(/\d+/,''))
}
