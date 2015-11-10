(function() {
  var debug, squel;

  debug = require('debug')('loopback-component-sqlizer');

  squel = require('squel');

  module["export"] = function(Model, options) {
    Model.sqlFind = function(filter, callback) {
      return callback();
    };
    Model.sqlFindone = function(filter, callback) {
      return callback();
    };
  };

}).call(this);
