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
  
  Model.__getTableName = (model) ->
    ds = Model.getDataSource()
    return ds.tableName model

  Model.__generateJoin = (q, model, filter) ->
    return if 'join' not of filter
    Origin = Model.app.models[model]
    originTable = Model.__getTableName model
    for join in filter.join
      if join.relation not of Origin.settings.relations
        continue
      relation = Origin.settings.relations[join.relation]
      destTable = Model.__getTableName relation.model
      expr = null
      if relation.type in ['hasMany', 'hasOne']
        expr = "#{originTable}.id = #{destTable}.#{relation.foreignKey}"
      else
        expr = "#{destTable}.id = #{originTable}.#{relation.foreignKey}"
      q.join Model.__getTableName(relation.model), null, expr
      if join.scope?.where
        Model.__generateWhere q, relation.model, join.scope.where
    return

  Model.__generateWhere = (q, model, where) ->
    expr = squel.expr()
    table = Model.getDataSource().tableName model
    for key, value of where
      column = Model.getDataSource().columnName model, key
      Model.__generateCondition expr, table, column, value
    q.where expr

  Model.__generateCondition = (expr, table, column, value) ->
    operators =
      like: 'LIKE'
      neq: '<>'
      gte: '>='
      lte: '<='
    if _.isObject value
      for skey, svalue of value
        if skey of operators
          expr.and "#{table}.#{column} #{operators[skey]} ?", svalue
    else
      expr.and "#{table}.#{column} = ?", value
  
  Model.__generateQuery = (filter, callback) ->
    modelName = @definition.name
    tableName = @__getTableName modelName
    q = squel.select()
    q.from tableName
    q.field "#{tableName}.*"
    @__generateJoin q, modelName, filter
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
