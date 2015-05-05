# imports
inflect = require('inflect')
pathToRegexp = require('path-to-regexp')
_ = require('underscore')


module.exports = (app, globalOptions = {})->

	# Define defaults for global options
	globalOptions = _.defaults(globalOptions, {
		# the URL prefix for all API calls
		namespace: '/'
	})
	
	# extend application instance with "expose" method to provide JSON API for models
	app.expose = (model, options = {}) ->

		# Define defaults for model options
		options = _.defaults(options, globalOptions)
		
		# namespace must begin with slash	
		if not options.namespace[..0] is '/'
			throw new Error('koa-seq-json: URL "namespace" option must begin with a slash or be "/"')

		# namespace must end with slash
		if not options.namespace[-1..] is '/'
			throw new Error('koa-seq-json: URL "namespace" option must end with a slash or be "/"')
	
		# generate model name
		modelName = inflect.pluralize(model.name.toLowerCase())
		
		# assemble model URL (/NS/modeName/<ID>)
		url = "#{options.namespace}#{modelName}/:id?"
	
		# convert to regular expression
		url = pathToRegexp(url)
	
		# create default request handlers
		options.find   ?= find(model)
		options.findAll ?= findAll(model)
		options.update ?= update(model)
		options.create ?= create(model)
		options.remove ?= remove(model)
		
		# associate URL handlers
		app.use (next)->

			# check if request URL matches pattern
			matches = url.exec(@path)
			if not matches
				return yield next
			
			# extract request ID parameter
			parameter = @state.modelId = matches[1]
			
			# find request
			if @method is "GET" and parameter
				 return yield options.find.call(@, next)

			# find all request
			if @method is "GET" and not parameter
				 return yield options.findAll.call(@, next)

			# update request
			if @method is "PUT" and parameter
				 return yield options.update.call(@, next)

			# create request
			if @method is "POST" and not parameter
				 return yield options.create.call(@, next)
			
			# delete request
			if @method is "DELETE" and not parameter
				 return yield options.remove.call(@, next)
			
			# no match found...
			yield next
		

find = (model)->
	return (next)->
		yield next

findAll = (model)->
	return (next)->
		yield next

update = (model)->
	return (next)->
		yield next

create = (model)->
	return (next)->
		yield next

remove = (model)->
	return (next)->
		yield next
