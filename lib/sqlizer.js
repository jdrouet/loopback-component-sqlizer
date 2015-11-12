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
    Model.__getTableName = function() {
      var ds;
      ds = Model.getDataSource();
      return ds.tableName(Model.definition.name);
    };
    Model.__generateQuery = function(filter, callback) {
      var q;
      q = squel.select();
      q.from(this.__getTableName(), '_origin_');
      q.field("_origin_.*");
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
