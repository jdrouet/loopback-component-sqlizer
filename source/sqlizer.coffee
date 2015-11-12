_     = require 'lodash'
debug = require('debug') 'loopback-component-sqlizer'
squel = require 'squel'

module.exports = (Model, options) ->

  #
  # PREPARE OPTIONS
  #

  defaultOptions =
    find:
      method: true
      remote: true
    findOne:
      method: true
      remote: true

  options = _.merge {}, defaultOptions, options

  #
  # COMMON
  #
  
  Model.__getTableName = ->
    ds = Model.getDataSource()
    return ds.tableName Model.definition.name
  
  Model.__generateQuery = (filter, callback) ->
    q = squel.select()
    q.from @__getTableName(), '_origin_'
    q.field "_origin_.*"
    if callback and _.isFunction callback
      return callback null, q.toParam()
    else
      return q.toParam()

  #
  # FIND
  #

  if options.find.method
    Model.sqlFind = (filter, callback) ->
      callback()

  #
  # FINDONE
  #

  if options.findOne.method
    Model.sqlFindOne = (filter, callback) ->
      callback()

  return
