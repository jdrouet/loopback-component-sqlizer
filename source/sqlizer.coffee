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

  Model.__getEngine = ->
    if @getDataSource().connector.settings.connector is 'postgresql'
      return squel.useFlavour 'postgres'
    return squel
 
  Model.__getTableName = (model) ->
    ds = @getDataSource()
    return ds.tableName model

  Model.__getColumnName = (model, field) ->
    ds = @getDataSource()
    return ds.columnName model, field

  Model.__buildJoin = (q, model, filter) ->
    return if 'join' not of filter
    Origin = @app.models[model]
    originTable = @__getTableName model
    for join in filter.join
      if join.relation not of Origin.settings.relations
        continue
      relation = Origin.settings.relations[join.relation]
      destTable = @__getTableName relation.model
      expr = null
      if relation.type in ['hasMany', 'hasOne']
        expr = "#{originTable}.id = #{destTable}.#{relation.foreignKey}"
      else
        expr = "#{destTable}.id = #{originTable}.#{relation.foreignKey}"
      q.join @__getTableName(relation.model), null, expr
      if join.scope?.where
        where = @__buildWhere(squel.expr(), 'and', relation.model, join.scope.where).toParam()
        # TO AVOID SQUEL BUG
        q.where.apply q.where, _.flatten [where.text, where.values]
    return

  Model.__buildWhere = (root, op, model, where) ->
    table = @__getTableName model
    for key, clauses of where
      if key in ['or', 'and'] and Array.isArray clauses
        root["#{key}_begin"]()
        for clause in clauses
          @__buildWhere root, key, model, clause
        root.end()
      else
        expression = clauses
        column = @__getColumnName model, key
        if expression is null or expression is undefined
          root[op] "#{table}.#{column} IS NULL"
        else if _.isObject expression
          for operator, value of expression
            if operator is 'like'
              root[op] "#{table}.#{column} LIKE ?", value
            else if operator is 'neq'
              root[op] "#{table}.#{column} <> ?", value
            else if operator is 'gte'
              root[op] "#{table}.#{column} >= ?", value
            else if operator is 'lte'
              root[op] "#{table}.#{column} <= ?", value
        else
          root[op] "#{table}.#{column} = ?", expression
    return root
  
  Model.__buildQuery = (filter) ->
    modelName = @definition.name
    tableName = @__getTableName modelName
    q = @__getEngine().select()
    q.from tableName
    q.field "#{tableName}.*"
    q.distinct()
    @__buildJoin q, modelName, filter
    return q.toParam()

  #
  # FIND
  #

  if options.find.method
    Model.sqlFind = (filter, options, callback) ->
      if _.isFunction(options) and not callback
        callback = options
        options = {}
      query = @__buildQuery filter
      connector = @getDataSource().connector
      self = @
      connector.execute query.text, query.values, options, (err, rows) ->
        return callback err if err
        objects = _.map rows, (item) ->
          connector.fromRow self.definition.name, item
        if filter?.include
          connector.getModelDefinition(self.definition.name).model.include objects, filter.include, options, callback
        else
          callback null, objects

    if options.find.remote
      Model.remoteMethod 'sqlFind',
        accepts: [
          {
            arg: 'filter'
            type: 'object'
            description: 'Filter defining fields, where, include, order, offset, and limit'
          }
        ]
        returns:
          arg: 'data'
          type: [Model.definition.name]
          root: true
        http:
          verb: 'get'
          path: '/sql-find-one'
  #
  # FINDONE
  #

  if options.findOne.method
    Model.sqlFindOne = (filter, options, callback) ->
      if _.isFunction(options) and not callback
        callback = options
        options = {}
      filter.limit = 1
      query = @__buildQuery filter
      connector = @getDataSource().connector
      self = @
      connector.execute query.text, query.values, options, (err, rows) ->
        return callback err if err
        return callback() if not rows or not Array.isArray(rows) or rows.length is 0
        object = connector.fromRow self.definition.name, rows[0]
        if filter?.include
          connector.getModelDefinition(self.definition.name).model.include object, filter.include, options, callback
        else
          callback null, object

    if options.findOne.remote
      Model.remoteMethod 'sqlFindOne',
        accepts: [
          {
            arg: 'filter'
            type: 'object'
            description: 'Filter defining fields, where, include, order, offset, and limit'
          }
        ]
        returns:
          arg: 'data'
          type: Model.definition.name
          root: true
        http:
          verb: 'get'
          path: '/sql-find-one'

  return
