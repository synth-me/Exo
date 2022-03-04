{
any,
all, 
at,
filter,
map,
head,
last,
intersection,
difference ,
flatten ,
zip,
zip-with, 
Str,
concat ,
flip,
reverse,
break-list,
elem-index,
take,
drop,
maximum-by,
maximum,
union,
initial,
split , 
Func,
Num,
is-type
} 					  = require "prelude-ls"
mqtt				  = require "mqtt"
fs 					  = require "fs"
similarity 			  = require "compute-cosine-similarity"
KNN 				  = require "ml-knn"
colors				  = require "colors"
art 				  = require "ascii-art"
cliProgress 		  = require "cli-progress"
express 			  = require "express"
commandline_argument  = require "process"


MVar = {}

class IO

	@puts    = -> (console.log it)
	@read    = -> fs.readFileSync it, "utf-8"
	@write   = (path,content) -> fs.writeFileSync path, content 
	@minsert = (mvar,content) -> mvar[0] = content

class MODEL

	@path = -> "./models/#{it}.json"
	@list = "./modelList.json"

class LOG 

	@puts  = -> IO.puts 	"----------- \n #{it} \n-----------"
	@alert = -> console.log "----------- \n ALERT :: \n #{it} \n-----------".yellow 
	@spawn = -> console.log "----------- \n #{it} \n-----------".green 


checkFile = (name,content,mode) ->
	| (name |> MODEL.path |> fs.existsSync) and (mode is "train")   =>
		data = name 
				|> MODEL.path
				|> IO.read
				|> JSON.parse
		
		(data.f_dataset).push content 
		data 
			|> JSON.stringify 
			|> IO.write (MODEL.path name), _
		
		"New #{content} written in #{name}" 
			|> IO.puts 

		return 1 
							 
		
	| (name |> MODEL.path |> fs.existsSync) and (mode isnt "train") => 
			data = name 
					|> MODEL.path
					|> IO.read
					|> JSON.parse
					|> (.f_dataset)
			try 
				[ i for i to data.length - 1]
					|> new KNN data, _, {k:1}
					|> (model) -> 
						p = model.predict [content]
						data
							|> map ((u) -> [u] |> model.predict )
							|> zip data 
							|> filter (-> (last it) === p)
							|> map (-> [it, (it |> head |> similarity content, _) ] )
							|> maximum-by (last)
							|> head << head
			catch 
				IO.puts "Could not classify #{content}"	
				return 0
			
					
	| not(name |> MODEL.path |> fs.existsSync) and (mode is "train")   => 

			formatted =	{f_dataset: [content] } |> JSON.stringify
			
			name 
				|> MODEL.path 
				|> IO.write _, formatted

			"New #{content} written in new model #{name}" 
				|> IO.puts
			return 1 
				
	| not(name |> MODEL.path |> fs.existsSync) and (mode isnt "train") => 
			return 0 
			

process = (message,client) -> 

	decoded = message 
	vector  = decoded.moment_data |> map last |> map((x) -> if is-type "Number" x then x else 1.0)
	mode_t  = decoded.mode  
	name 	= decoded.name_log

	c = checkFile name, vector, mode_t 
	
	switch c 
		| 0 => 
			"notifications" 
				|> client.publish _, "error on #{name} resilience model"
		| 1 => 
			"notifications"
				|> client.publish _, "training #{name} ..."
		| _ => 
			"notifications"
				|> client.publish _, "Resilience is on ! check the #{name} aggregator ..."								
	
	if c isnt 0 and c isnt 1 
		then 	
			d = decoded.moment_data 
				|> zip-with ((x,y) -> [(head x),y] ), _, c  	
			v = {
				name_log: decoded.name_log
				current_data: d 
			} |> JSON.stringify
			return v 
		else
			{}
		
Resilience = {
	process_data: process
}

export Resilience
