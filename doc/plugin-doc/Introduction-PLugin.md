# Introduction to the heart of all of this : plugins !


## What are plugins ? What do they eat ? Where they live ? 

So the bigger star of the show is the **plugins**, they're made to process the information from the aggregators
and make them useful and influence and the rest to system's hardware. 
Plugins are basically little programs made to process the data, with some specificalities that will help the user
to process data using libraries made to it. The plugins can be written in any language that compiles to javascript
and we recommend : livescript and purescript. Those are two languages that fit the rest of the Exo's philosophy of
functional programming and have the best match for our data-oriented library. 

## Anatomy of a plugin 

The plugins have the following data structure to be configured : 

```json

{
	"name":"moduleX",
	"agg_route":["A","B"],
	"script_path":"test_X"
}

```

The "agg_route" attribute describes the aggregators the plugins will listen to. In the same way the aggregators
are responsible for organizing the information that comes from multiple sensors, we can think that plugins are responsable
for processing and organizing the information that comes from multiple aggreagators. In this case the aggregators 
being listened to are **A** and **B** , and the plugin is names **test_X**. 


## Processing information 

So, how does the information is actually processed ? The information that is generated , and that goes as input to the 
plugin, is storage by the auxiliary server as a global variable called INPT and it's a list of aggregators output. In 
the current case we can imagine a INPT information like the following : 

```json 
[
	{"name_agg":"B","current_data":[
		["sensor/B/moisture-1",1]
	]},
	{"name_agg":"A","current_data":[
		["sensor/A/moisture-2",1]
	]}
]
```

So that's the general structure one must have in mind while coding a plugin. Inside the plugin itself, we can access
the information as any other global variable. 
The plugin is run everytime a new sensor publishes a new information, which means one code the plugins as a single 
data processing pipeline without infinity loops or very time consuming requests, otherwise that will block the Exo
system. 
To help the information export and processing we have a library called **plumbing** which will help the user to define
functions processing pipelines and chaining. To evoke the end of the plugin execution we have a special function called
**EXPORT** and to publish a value on a topic we can use **CLIENT** ( which is the auxiliar server's client already 
connected to the broker, so no need to connect it). The following is an example of a basic plugin written in livescript.

```ls
main = do 
	"turn-on" |> CLIENT.publish "light"
	INPT	  |> EXPORT 
```

This is a simple example, where we publish a string called "turn-on" in the topic "light" and then export the 
input information without any transformation. The CLIENT function is useful when you need to give orders to hardware 
that is connected to the broker and listening to specific topics. 

The system also exposes a data-oriented library called "plumbing" that helps the user in writing expressive
pipelines of data processing with much less pain ! Some of it's functions includes :

* FilterSensorData : extracts only the pure numerical information from aggreagtors
* Report : create a report to output well formated data out of the plugin 
* PatternPipe : run and compile a list of results from a list of functions for a single value 

The list of functions will get bigger, but it's important to use such a library so that manipulating
the input information get easier and faster. The inclusion of that library is **implicity** so no 
importing statment is needed. 

## JS pipelines 

As said before the plugins must be written a language that can compile to js. There's a trick here to help this feature
called **compilation pipelines**. Those are perl written little recipes of how to compile a specific languages to 
javascript. For example in livescript, given livescript is installed in your machine, the perl code will enter 
the plugin's specific directory and run "lsc -c X" for every .ls file and then compiling it into useful .js files. 
That can be repeated to every supported language until now which are : 

* purescript 
* livescript
* ruby 
* coffeescript
* typescript

Those pipelines will be specially useful when we deal with packages, in the **packages section**.
But never forget you **must have the compiler installed** otherwise the recipes won't find it's way through it. 
This schematic represents how the interface **epm** connects to the pipelines system and compiles everything : 

<img src="./resources/pipelines-scheme.png">
