# Author: Yuri Vyatkin https://github.com/yurivyatkin
# Date: August 2015
# Licence: MIT
module.exports = (grunt) ->

	# Project configuration
	grunt.initConfig

		# Configurable paths
		pathto:
			source: 'app'
			build: 'dist'

		# Define Connect web server
		connect:
			server:
				options:
					port: 9000
					hostname: 'localhost'
					base: '<%= pathto.build %>'
					livereload: true

		# Watch files for changes
		watch:
			options:
				livereload: true
			# targets for watch
			coffee:
				files: ['<%= pathto.source %>/**/*.coffee']
				tasks: ['coffee']
			stylus:
				files: ['<%= pathto.source %>/**/*.styl']
				tasks: ['stylus']
			jade:
				files: ['<%= pathto.source %>/**/*.jade']
				tasks: ['jade']
			copy:
				files: [
					'<%= pathto.source %>/**'
					'!<%= pathto.source %>/**/*.coffee'
					'!<%= pathto.source %>/**/*.styl'
					'!<%= pathto.source %>/**/*.jade'
				]
				tasks: ['copy']

		# Compile Jade
		jade:
			compile:
				options:
					pretty: true
					data: {}
				files: [
					expand: true
					cwd: '<%= pathto.source %>'
					src: ['**/*.jade']
					dest: '<%= pathto.build %>'
					ext: '.html'
				]

		# Compile Stylus
		stylus:
			compile:
				options:
					# linenos: true
					compress: false
				files: [
					expand: true
					cwd: '<%= pathto.source %>'
					src: ['**/*.styl']
					dest: '<%= pathto.build %>'
					ext: '.css'
				]

		# Compile CoffeeScript
		coffee:
			compile:
				files: [
					expand: true
					cwd: '<%= pathto.source %>'
					src: ['**/*.coffee']
					dest: '<%= pathto.build %>'
					ext: '.js'
				]

		# Copy the necessary files to the build
		copy:
			build:
				cwd: '<%= pathto.source %>'
				src: [
					'**'
					'!**/*.jade'
					'!**/*.styl'
					'!**/*.coffee'
				]
				dest: '<%= pathto.build %>'
				expand: true

		# Clean the build directory:
		clean:
			# gegeral cleaning:
			build:
				src: '<%= pathto.build %>/**'
			# clean up styles after minification:
			styles:
				src: [
					'<%= pathto.build %>/**/*.css'
					'!<%= pathto.build %>/**/app.css'
				]
			# clean up scripts after minification:
			scripts:
				src: [
					'<%= pathto.build %>/**/*.js'
					'!<%= pathto.build %>/**/app.js'
				]

		# Minify CSS files and concatenate them into app.css
		cssmin:
			build:
				files:
					'<%= pathto.build %>/app.css': ['<%= pathto.build %>/**/*.css']

		# Remove unused styles from CSS
		uncss:
			build:
				files:
					'<%= pathto.build %>/app.css': [
						'<%= pathto.build %>/index.html'
					]

		# Use PostCSS to run Autoprefixer plugin
		postcss:
			options:
				processors: [
					# add vendor prefixes
					require('autoprefixer-core')
						browsers: 'last 2 versions'
				]
			dist:
				src: '<%= pathto.build %>/**/*.css'

		# Minify javascript files and concatenate them inot app.js
		uglify:
			build:
				options:
					mangle: false
				files:
					'<%= pathto.build %>/app.js': ['<%= pathto.build %>/**/*.js']

		# Update HTML files with minified versions of stylesheets and scripts
		processhtml:
			dist:
				files:
					'<%= pathto.build %>/index.html': ['<%= pathto.build %>/index.html']

	# Instead of adding `grunt.loadNpmTasks` every time
	# loading external tasks (aka: plugins) programmatically:
	require('matchdep').filterAll('grunt-*').forEach(grunt.loadNpmTasks)

	# Configure workflows

	# Running `grunt server` runs the Connect server until terminated
	grunt.registerTask 'server', ['connect:server:keepalive']

	# Process stylesheets
	grunt.registerTask 'stylesheets', [
		'cssmin'
		'uncss'
		'postcss'
		'clean:styles'
	]

	# Process scripts
	grunt.registerTask 'scripts', [
		'uglify'
		'clean:scripts'
	]

	# Build the development version
	grunt.registerTask 'build', [
		'clean'
		'copy'
		'jade'
		'coffee'
		'stylus'
	]

	# Build the production version
	grunt.registerTask 'prod', [
		'build'
		'stylesheets'
		'scripts'
		'processhtml'
	]

	# Run the development pipeline
	grunt.registerTask 'default', [
		'build'
		'connect'
		'watch'
	]
