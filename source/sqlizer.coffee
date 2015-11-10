debug = require('debug') 'loopback-component-sqlizer'
squel = require 'squel'

module.export = (Model, options) ->

  Model.sqlFind = (filter, callback) ->
    callback()

  Model.sqlFindone = (filter, callback) ->
    callback()

  return
