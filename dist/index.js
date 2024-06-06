
'use strict'

if (process.env.NODE_ENV === 'production') {
  module.exports = require('./comet-ens-serve.cjs.production.min.js')
} else {
  module.exports = require('./comet-ens-serve.cjs.development.js')
}
