# imports
inflect = require('inflect')
pathToRegexp = require('path-to-regexp')
bodyParser = require('koa-bodyparser')()
_ = require('underscore')


# usage: require('koa-sequelize-json')(app, {<options>})
# options: namespace, modelname, find, findAll, update, create, remove
module.exports = (app, globalOptions = {})->

	# Define defaults for global options
	globalOptions = _.defaults(globalOptions, {
		# the URL prefix for all API calls
		namespace: '/'

		# action generator functions - names will be called for queries with 'action' URL parameter
		actions: {}
	})
	
	# extend application instance with "expose" method to provide JSON API for models
	app.expose = (Model, options = {}) ->

		# Define defaults for model options
		options = _.defaults(options, globalOptions, {
			
			# generate default model name
			modelName: inflect.pluralize(Model.modelName.toLowerCase())
		})
		
		# namespace must begin with slash	
		if not options.namespace[..0] is '/'
			throw new Error('koa-seq-json: URL "namespace" option must begin with a slash or be "/"')

		# namespace must end with slash
		if not options.namespace[-1..] is '/'
			throw new Error('koa-seq-json: URL "namespace" option must end with a slash or be "/"')
	
				
		# assemble model URL (/NS/modeName/<ID>)
		url = "#{options.namespace}#{options.modelName}/:id?"
	
		# convert to regular expression
		url = pathToRegexp(url)
	
		# create default request handlers
		options.find   ?= find(Model)
		options.findAll ?= findAll(Model)
		options.update ?= update(Model)
		options.create ?= create(Model)
		options.remove ?= remove(Model)
		options.query ?= query(Model)
		
		# associate URL handlers
		app.use (next)->

			# check if request URL matches pattern
			matches = url.exec(@path)
			if not matches
				return yield next

			# add sequelize model class to state
			@state.Model = Model

			# extract request ID parameter and add to state
			parameter = @state.modelId = matches[1]

			# find request
			if @method is "GET" and parameter
				return yield options.find.call(@, next)

			# query or action request
			else if @method is "GET" and @request.query
				return yield (options.actions[@request.query.action] || options.query).call(@, next)
				 
			# find all request
			if @method is "GET" and not parameter
				return yield options.findAll.call(@, next)

			# update request
			if @method is "PUT" and parameter
				return yield bodyParser.call(@, options.update.call(@, next))

			# create request
			if @method is "POST" and not parameter
				return yield bodyParser.call(@, options.create.call(@, next))

			# delete request
			if @method is "DELETE" and not parameter
				return yield options.remove.call(@, next)
			
			# no match found...
			yield next
		

find = (Model)->
	return (next)->
		yield next

query = (Model)->
	return (next)->
		yield next

findAll = (Model)->
	return (next)->
		yield next

update = (Model)->
	return (next)->
		yield next

create = (Model)->
	return (next)->
		yield next

remove = (Model)->
	return (next)->
		yield next
