gulp = module.exports = require 'gulp'
plugins = require('gulp-load-plugins')()
require('./client')(gulp, plugins)

gulp.task 'default', ['client']