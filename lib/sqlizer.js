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
    Model.__getTableName = function(model) {
      var ds;
      ds = Model.getDataSource();
      return ds.tableName(model);
    };
    Model.__generateJoin = function(q, model, filter) {
      var Origin, destTable, expr, i, join, len, originTable, ref, ref1, ref2, relation;
      if (!('join' in filter)) {
        return;
      }
      Origin = Model.app.models[model];
      originTable = Model.__getTableName(model);
      ref = filter.join;
      for (i = 0, len = ref.length; i < len; i++) {
        join = ref[i];
        if (!(join.relation in Origin.settings.relations)) {
          continue;
        }
        relation = Origin.settings.relations[join.relation];
        destTable = Model.__getTableName(relation.model);
        expr = null;
        if ((ref1 = relation.type) === 'hasMany' || ref1 === 'hasOne') {
          expr = originTable + ".id = " + destTable + "." + relation.foreignKey;
        } else {
          expr = destTable + ".id = " + originTable + "." + relation.foreignKey;
        }
        q.join(Model.__getTableName(relation.model), null, expr);
        if ((ref2 = join.scope) != null ? ref2.where : void 0) {
          Model.__generateWhere(q, relation.model, join.scope.where);
        }
      }
    };
    Model.__generateWhere = function(q, model, where) {
      var column, expr, key, table, value;
      expr = squel.expr();
      table = Model.getDataSource().tableName(model);
      for (key in where) {
        value = where[key];
        column = Model.getDataSource().columnName(model, key);
        Model.__generateCondition(expr, table, column, value);
      }
      return q.where(expr);
    };
    Model.__generateCondition = function(expr, table, column, value) {
      var operators, results, skey, svalue;
      operators = {
        like: 'LIKE',
        neq: '<>',
        gte: '>=',
        lte: '<='
      };
      if (_.isObject(value)) {
        results = [];
        for (skey in value) {
          svalue = value[skey];
          if (skey in operators) {
            results.push(expr.and(table + "." + column + " " + operators[skey] + " ?", svalue));
          } else {
            results.push(void 0);
          }
        }
        return results;
      } else {
        return expr.and(table + "." + column + " = ?", value);
      }
    };
    Model.__generateQuery = function(filter, callback) {
      var modelName, q, tableName;
      modelName = this.definition.name;
      tableName = this.__getTableName(modelName);
      q = squel.select();
      q.from(tableName);
      q.field(tableName + ".*");
      this.__generateJoin(q, modelName, filter);
      if (callback && _.isFunction(callback)) {
        return callback(null, q.toParam());
      } else {
        return q.toParam();
      }
    };
    if (options.find.method) {
      Model.sqlFind = function(filter, callback) {
        return callback();
      };
    }
    if (options.findOne.method) {
      Model.sqlFindOne = function(filter, callback) {
        return callback();
      };
    }
  };

}).call(this);
