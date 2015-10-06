del = require 'del'
browserSync = require 'browser-sync'
sequence = require 'run-sequence'
fs = require('fs')


module.exports = (gulp, $) ->

  dst = './'

  gulp.task 'client-sass', ->
    return gulp.src(['./src/**/*.scss', './src/**/_*.scss'])
      .pipe($.changed(dst))
      .pipe($.plumber())
      .pipe($.sass())
      .pipe(gulp.dest(dst))

  gulp.task 'client-sass-watch', ->
    $.watch ['./src/**/*.scss'], () ->
      gulp.start 'client-sass', ->
        browserSync.reload("*.css")
    return


  gulp.task 'client-coffee', ->
    return gulp.src(['./src/**/*.coffee'])
      .pipe($.changed(dst))
      .pipe($.plumber())
      .pipe($.coffee())
      .pipe(gulp.dest(dst))

  gulp.task 'client-coffee-watch', ->
    $.watch ['./src/**/*.coffee'], () ->
      gulp.start 'client-coffee', ->
        browserSync.reload()
    return


  gulp.task 'client-jade', ->
    return gulp.src(['./src/**/*.jade'])
      .pipe($.changed(dst))
      .pipe($.plumber())
      .pipe($.jade())
      .pipe(gulp.dest(dst))

  gulp.task 'client-jade-watch', ->
    $.watch ['./src/**/*.jade'], () ->
      gulp.start 'client-jade', ->
        browserSync.reload()
    return


  gulp.task 'client-copy', ->
    return gulp.src(['./src/**/*.html', './src/**/*.js', './src/**/*.css', './src/**/*.png'])
      .pipe($.changed(dst))
      .pipe(gulp.dest(dst))

  gulp.task 'client-copy-watch', ->
    $.watch ['./src/**/*.html', './src/**/*.js','./src/**/*.css', './src/**/*.png'], () ->
      gulp.start 'client-copy', ->
        browserSync.reload()
    return


  gulp.task 'browser-sync', ->
    browserSync({server: dst})
    return


  gulp.task 'client-clean', (cb) ->
    del(['./build/static/*.*'], cb)
    return;

  gulp.task 'client-build', (cb) ->
    sequence(
      'client-copy',
      'client-sass',
      'client-jade',
      'client-coffee',
      cb)
    return

  gulp.task 'client-watch', (cb) ->
    sequence(
      'client-copy-watch',
      'client-sass-watch',
      'client-jade-watch',
      'client-coffee-watch',
      cb)
    return

  gulp.task 'client', (cb) ->
    sequence(
      'client-clean'
      'client-build',
      'client-watch',
      'browser-sync',
      cb)
    return
