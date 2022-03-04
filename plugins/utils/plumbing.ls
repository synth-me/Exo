{
	map,
	filter,
	zip-all,
	zip,
	head,
	all,
	last,
	Func,
	Obj
} = require \prelude-ls

# GenericAggregator :: String -> [(String,Float)]
GenericAggregator = Func.curry (name_log,moment_data) -> 
	{
		name_log: name_log, 
		moment_data: moment_data
	}	

# FilterSensorData :: GenericAggregator -> [Float]
FilterSensorData = (probe) -> 
	probe 
		|> (.moment_data)
		|> map last

# Report :: String -> String -> [String]
Report = Func.curry (warnKind,reviewStatus,logBody) ->
	{
		warnKind: warnKind,
		reviewStatus: reviewStatus,
		logBody: logBody
	}


# logReport :: Int -> String -> [String]
logReport = (mode,warn,log) ->
	| mode is 0 => Report warn "Sucess" log
	| mode is 1 => Report warn "Warning" log
	| mode is 2 => Report warn "Redirect" log
		

# PatternPipe :: forall a b . [a -> Bool] -> [a -> b] -> Pipe 
PatternPipe = Func.curry (t,vf) -> 
	{test: t,pipeline: vf }

# flowWith :: forall a. a -> [Pipe]
flowWith = Func.curry (pattern,value) -> 
	pattern.test
		|> map ((x) -> x value ) 
		|> all (is true)
		|> ->
			| it is true => 
				map ((x) -> x value), pattern.pipeline 
			| _  => 
				[]

Plumbing = {
	PatternPipe:PatternPipe,
	flowWith:flowWith
}

Utilities = {
	GenericAggregator: GenericAggregator,
	Report : Report,
	logReport : logReport,
	FilterSensorData: FilterSensorData
}

export Plumbing
	

