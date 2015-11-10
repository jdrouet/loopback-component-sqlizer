gulp      = require 'gulp'
coffee    = require 'gulp-coffee'
mocha     = require 'gulp-mocha'
plumber   = require 'gulp-plumber'

gulp.task 'default', ['build']

gulp.task 'build', ->
  gulp.src 'source/*.coffee'
  .pipe coffee()
  .pipe gulp.dest 'lib'

gulp.task 'test', ->
  gulp.src 'test/*.coffee', read: false
  .pipe plumber()
  .pipe mocha
    require: ['./test/requirements.coffee']

gulp.task 'watch', ['build', 'test'], ->
  gulp.watch 'source/*.coffee', ['build', 'test']
  gulp.watch 'test/*.coffee', ['test']
