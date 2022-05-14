// Entry point for the build script in your package.json
import jquery from 'jquery'
window.jQuery = jquery
window.$ = jquery

import * as bootstrap from 'bootstrap'
import * as bootstrapTable from 'bootstrap-table'
import './esi-async-loading'
import './table-sorting'
