del = require 'del'
browserSync = require 'browser-sync'
sequence = require 'run-sequence'
fs = require('fs')
inlinesource = require('gulp-inline-source')

isRelease = false

module.exports = (gulp, $, options) ->

  dst = '../'

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
      # .pipe(inlinesource({rootpath: './', compress: options.compress}))
      .pipe(gulp.dest(dst))

  createJadeTask = (taskName, file, base, rootpath) ->
    gulp.task taskName, ->
      return gulp.src([file], {base: base})
        .pipe($.changed(dst))
        .pipe($.plumber())
        .pipe($.jade())
        # .pipe(inlinesource({rootpath: rootpath, compress: options.compress}))
        .pipe(gulp.dest(dst))
    return undefined

  gulp.task 'client-jade-watch', ->
    $.watch ['./src/**/*.jade'], (file) ->
      tn = 'client-jade-temp'
      createJadeTask tn, file.history[file.history.length - 1], file.base, file.cwd

      # console.log Object.keys(file)
      # for k in Object.keys(file)
      #   console.log(file[k])

      gulp.start tn, ->
        browserSync.reload()
    return

  copy = [
    './src/**/*.html'
    './src/**/*.js'
    './src/**/*.css'
    './src/**/*.png'
    './src/**/*.gif'
    './src/**/*.svg'
  ]

  gulp.task 'client-copy', ->
    return gulp.src(copy)
      .pipe($.changed(dst))
      .pipe(gulp.dest(dst))

  gulp.task 'client-copy-watch', ->
    $.watch copy, () ->
      gulp.start 'client-copy', ->
        browserSync.reload()
    return


  gulp.task 'browser-sync', ->
    browserSync(
      server:
        baseDir: dst
      online: false
      ghostMode: false
      )
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
