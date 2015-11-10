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
    Model.__generateQuery = function(filter, callback) {
      return callback();
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
