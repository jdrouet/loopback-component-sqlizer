gulp      = require 'gulp'
coffee    = require 'gulp-coffee'
plumber   = require 'gulp-plumber'

gulp.task 'default', ['build']

gulp.task 'build', ->
  gulp.src 'source/*.coffee'
  .pipe coffee()
  .pipe gulp.dest 'lib'

gulp.task 'watch', ['build'], ->
  gulp.watch 'source/*.coffee', ['build']
