# Packages - Like taking candy from baby ! 

Packges were tought to facilitate the installation and distribution of pre-configured aggregators, plugins and 
schedulers for other Exo users. This will facilitate the distribution of already made iot system by companies 
with a unique platform with simple and organized apis. 

## The structure of a pacakage 

The following structure is a json that must be your folder when creating your package : 

```json

{
	"package_name": "Package Example",
	"dependencies": [],
	"package_aggr": [
		{
			"name_agg": "A",
			"routes": "A"
		},
		{
			"name_agg": "B",
			"routes": "B"
		}
	],
	"package_plugin_config": [
		{
			"name_module": "module1",
			"agg_route": ["B","A"],
			"script_path": "test_module"
		}
	]
}
```

we have here 4 keys, in order , the name of the package , some dependencies ( to be made ) , your aggregator's definition
and your plugin's definition. As you can see it's easy because each key defines in a list all your aggregators and plugins
and that's it. In this case the plugin defined listens to the aggregators defined here **A** and **B**. And that's a 
good pratice : define the aggregators you'll use. 

In the same folder as you putted this **index.json** you must put all the source code that you defined. In this case 
**test_module**. Only use the name of the file, because if pre-processing is needed then the compiler will deal with
defining the file's extension. 

``` 

package 
	- index.json
	- test_module.ls

```

After your making your folder, you must upload it to github so that other users can clone your repo ! and that's it
for defining new redistributable packages. 


