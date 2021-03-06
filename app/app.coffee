define [
		## Libs
		"jquery"
		"underscore"
		"backbone"
		"handlebars"
		"plugins/backbone.layoutmanager"
	],

	($, _, Backbone, Handlebars) ->
		app =
			root: '/'

		JST = window.JST = window.JST || {}

		Backbone.LayoutManager.configure
			manage: true

			prefix: "app/templates/"

			fetch: (path) ->
				done = undefined
				path = path + '.html'

				# If the template has not been loaded yet, then load.
				unless JST[path]
					done = @.async()
					return $.ajax(url: app.root + path).then((contents) ->
						JST[path] = Handlebars.compile contents
						JST[path].__compiled__ = true
						done JST[path]
					)

				# If the template hasn't been compiled yet, then compile.
				unless JST[path].__compiled__
					JST[path] = Handlebars.template JST[path]
					JST[path].__compiled__ = true
				
				JST[path]

		# Mix Backbone.Events, modules, and layout management into the app object.
		return _.extend app, {
			# Create a custom object with a nested Views object.
			module: (additionalProps) ->
				_.extend { Views: {} }, additionalProps

			# Helper for using layouts.
			useLayout: (name, options) ->
				# If already using this Layout, then don't re-inject into the DOM.
				if @.layout and @.layout.options.template is 'layouts/' + name
					return @.layout

				# If a layout already exists, remove it from the DOM.
				if @.layout then @.layout.remove()

				# Create a new Layout with options.
				layout = new Backbone.Layout _.extend({
					template: 'layouts/' + name
					className: "layout " + name
					id: "layout"
				}, options)

				# Insert into the DOM.
				$("#main").empty().append layout.el

				# Render the layout.
				layout.render()

				# Cache the refererence.
				@.layout = layout

				# Return the reference, for chainability.
				return layout
		}, Backbone.Events