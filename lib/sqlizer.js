(function() {
  var _, debug, squel;

  _ = require('lodash');

  debug = require('debug')('loopback-component-sqlizer');

  squel = require('squel');

  module.exports = function(Model, options) {
    var defaultOptions;
    defaultOptions = {
      find: {
        method: true,
        remote: true
      },
      findOne: {
        method: true,
        remote: true
      }
    };
    options = _.merge({}, defaultOptions, options);
    Model.__getEngine = function() {
      if (this.getDataSource().connector.settings.connector === 'postgresql') {
        return squel.useFlavour('postgres');
      }
      return squel;
    };
    Model.__getTableName = function(model) {
      var ds;
      ds = this.getDataSource();
      return ds.tableName(model);
    };
    Model.__getColumnName = function(model, field) {
      var ds;
      ds = this.getDataSource();
      return ds.columnName(model, field);
    };
    Model.__buildJoin = function(q, model, filter) {
      var Origin, destTable, expr, i, join, len, originTable, ref, ref1, ref2, relation;
      if (!('join' in filter)) {
        return;
      }
      Origin = this.app.models[model];
      originTable = this.__getTableName(model);
      ref = filter.join;
      for (i = 0, len = ref.length; i < len; i++) {
        join = ref[i];
        if (!(join.relation in Origin.settings.relations)) {
          continue;
        }
        relation = Origin.settings.relations[join.relation];
        destTable = this.__getTableName(relation.model);
        expr = null;
        if ((ref1 = relation.type) === 'hasMany' || ref1 === 'hasOne') {
          expr = originTable + ".id = " + destTable + "." + relation.foreignKey;
        } else {
          expr = destTable + ".id = " + originTable + "." + relation.foreignKey;
        }
        q.join(this.__getTableName(relation.model), null, expr);
        if ((ref2 = join.scope) != null ? ref2.where : void 0) {
          q.where(this.__buildWhere(squel.expr(), 'and', relation.model, join.scope.where));
        }
      }
    };
    Model.__buildWhere = function(root, op, model, where) {
      var clause, clauses, column, expression, i, key, len, operator, table, value;
      table = this.__getTableName(model);
      for (key in where) {
        clauses = where[key];
        if ((key === 'or' || key === 'and') && Array.isArray(clauses)) {
          root[key + "_begin"]();
          for (i = 0, len = clauses.length; i < len; i++) {
            clause = clauses[i];
            this.__buildWhere(root, key, model, clause);
          }
          root.end();
        } else {
          expression = clauses;
          column = this.__getColumnName(model, key);
          if (expression === null || expression === void 0) {
            root[op](table + "." + column + " IS NULL");
          } else if (_.isObject(expression)) {
            for (operator in expression) {
              value = expression[operator];
              if (operator === 'like') {
                root[op](table + "." + column + " LIKE ?", value);
              } else if (operator === 'neq') {
                root[op](table + "." + column + " <> ?", value);
              } else if (operator === 'gte') {
                root[op](table + "." + column + " >= ?", value);
              } else if (operator === 'lte') {
                root[op](table + "." + column + " <= ?", value);
              }
            }
          } else {
            root[op](table + "." + column + " = ?", expression);
          }
        }
      }
      return root;
    };
    Model.__buildQuery = function(filter) {
      var modelName, q, tableName;
      modelName = this.definition.name;
      tableName = this.__getTableName(modelName);
      q = this.__getEngine().select();
      q.from(tableName);
      q.field(tableName + ".*");
      this.__buildJoin(q, modelName, filter);
      return q.toParam();
    };
    if (options.find.method) {
      Model.sqlFind = function(filter, callback) {
        var connector, query, self;
        query = this.__buildQuery(filter);
        connector = this.getDataSource().connector;
        self = this;
        console.log(query.text);
        return connector.execute(query.text, query.values, {}, function(err, rows) {
          var objects;
          if (err) {
            return callback(err);
          }
          objects = _.map(rows, function(item) {
            return connector.fromRow(self.definition.name, item);
          });
          if (filter != null ? filter.include : void 0) {
            return connector.getModelDefinition(model).model.include(objects, filter.include, {}, callback);
          } else {
            return callback(null, objects);
          }
        });
      };
    }
    if (options.findOne.method) {
      Model.sqlFindOne = function(filter, callback) {
        return callback();
      };
    }
  };

}).call(this);
