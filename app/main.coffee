require [
	"namespace"

	## Libs
	"jquery"
	"use!backbone" 

	## Modules
	"modules/example"
], (namespace, $, Backbone, Example) ->

	## Defining the application router, you can attach sub routers here.
	Router = Backbone.Router.extend(
		routes:
			"": "index"
			":hash": "index"

		index: (hash) ->
			tutorial = new Example.Views.Tutorial()

			## Attach the tutorial to the DOM
			tutorial.render (el) ->
				$("#main").html el

				## Fix for hashes in pushState and hash fragment
				if hash and not @._alreadyTriggered
					## Reset to home, pushState support automatically converts hashes
					Backbone.history.navigate "", false

					## Trigger the default browser behavior
					location.hash = hash

					## Set an internal flag to stop recursive looping
					@._alreadyTriggered = true
	)

	## Shorthand the application namespace
	app = namespace.app

	## Treat the jQuery ready function as the entry point to the application.
	## Inside this function, kick-off all initialization, everything up to this
	## point should be definitions.
	$ ->
		app.router = new Router()
		Backbone.history.start pushState: true
		
	## All navigation that is relative should be passed through the navigate
	## method, to be processed by the router.  If the link has a data-bypass
	## attribute, bypass the delegation completely.
	$(document).on "click", "a:not([data-bypass])", (evt) ->
		## Get the anchor href and protocol
		href = $(this).attr("href")
		protocol = @protocol + "//"
		## Ensure the protocol is not part of URL, meaning its relative.
		if href and href.slice(0, protocol.length) isnt protocol and href.indexOf("javascript:") isnt 0

			## Stop the default event to ensure the link will not cause a page refresh.
			evt.preventDefault()
			## `Backbone.history.navigate` is sufficient for all Routers and will
			## trigger the correct events.  The Router's internal `navigate` method
			##calls this anyways.
			Backbone.history.navigate href, true