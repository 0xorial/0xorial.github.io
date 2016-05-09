del = require 'del'
browserSync = require 'browser-sync'
sequence = require 'run-sequence'
fs = require('fs')
inlinesource = require('gulp-inline-source')
historyApiFallback = require('connect-history-api-fallback')
express = require('express')


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
        $.livereload.reload("*.css")
    return


  gulp.task 'client-coffee', ->
    return gulp.src(['./src/**/*.coffee'])
      .pipe($.changed(dst, {extension: '.js'}))
      .pipe($.plumber())
      .pipe($.sourcemaps.init({identityMap: true}))
      .pipe($.coffee())
      .pipe($.sourcemaps.write({mapSources: (f) -> '/build/src/' + f}))
      .pipe(gulp.dest(dst))

  gulp.task 'client-coffee-watch', ->
    $.watch ['./src/**/*.coffee'], () ->
      gulp.start 'client-coffee', ->
        $.livereload.reload()
    return


  gulp.task 'client-jade', ->
    return gulp.src(['./src/**/*.jade'])
      .pipe($.changed(dst, {extension: '.html' }))
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
        $.livereload.reload()
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
        $.livereload.reload()
    return


  gulp.task 'browser-sync', ->
    server = express()
    server.use($.livereload.middleware({port: 3003}))
    server.use(express.static(dst))
    server.listen(3000)
    $.livereload.listen({
      port: 3003
      host: 'localhost'
      start: true
      basePath: dst
      })
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
