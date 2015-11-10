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

  Model.__generateQuery = (filter, callback) ->
    callback()

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
