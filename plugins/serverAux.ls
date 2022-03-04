express = require \express
mqtt 	= require \mqtt
fs 		= require \fs
{
	Plumbing,
	Utilities
} = require "./utils/plumbing.ls"
{ Resilience } = require "./Resilience.ls"

console.log Resilience 

PORT    		= process.argv[4] |> parseInt
CLIENT  		= mqtt.connect("mqtt://localhost:1883")
REBUILD 		= (pack) -> 
	v = {
		name_log: pack.name_log
		mode: "corrupted",
		moment_data: pack.current_data
	}
	|> Resilience.process_data _, CLIENT   	

express! 

	..get "/run", (request,response) -> 
		
		EXPORT = response.send _
		INPT = request 
				|> (.query) 
				|> (.input)
				|> JSON.parse
		
		NAME_PLUGIN = request
				|> (.query) 
				|> (.name) 

		try
			NAME = NAME_PLUGIN 
			fs.readFileSync "./rules/#{NAME_PLUGIN}.js" , "utf-8" |> eval  
		catch {message}
			failure = 
					logBody:[message]
					reviewStatus: "Script syntax error"
					warnKind: "Failure"
			CLIENT.publish "notifications", JSON.stringify(failure)
			failure |> EXPORT 
				
	..listen PORT, -> 
		"Running => #{PORT}" 
			|> console.log

CLIENT 
	..subscribe "notification/resilience/#"
	..on "message", (t,m) -> 
						m.toString! 
							|> JSON.parse 
							|> Resilience.process_data  _, CLIENT

# eof 
