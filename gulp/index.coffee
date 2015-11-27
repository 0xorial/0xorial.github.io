gulp = module.exports = require 'gulp'
plugins = require('gulp-load-plugins')()
argv = require('yargs').argv
_ = require 'lodash'

options = {}

_.merge options, argv

defaultOptions = {
  compress: false
}

if argv.release
  defaultOptions.compress = true

_.defaults(options, defaultOptions)


require('./client')(gulp, plugins, options)

gulp.task 'default', ['client']
