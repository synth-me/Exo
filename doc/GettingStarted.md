# Getting Started ! 

### Downloading :: 

You can compile the source code yourself ( if you want to contribute with code ) or 
you can download the precompiled version for your platform 

* [Windows] 
* [Linux]  

### Compiling :: 

To compile the Exo yourself you must have the following dependencies installed 

* ![Haskell](https://img.shields.io/badge/Haskell-5e5086?style=for-the-badge&logo=haskell&logoColor=white) (stack and ghc)
* ![NodeJS](https://img.shields.io/badge/node.js-6DA55F?style=for-the-badge&logo=node.js&logoColor=white)
* ![Python](https://img.shields.io/badge/python-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54)
* ![Perl](https://img.shields.io/badge/perl-%2339457E.svg?style=for-the-badge&logo=perl&logoColor=white)

and then you can run , in the Exo's folder **./exo** :

```ps
perl compile.pl 
```

Before starting an Exo instance we need to make sure Exo will be able to connect with your broker. Some http ports
must be free as well. The configuration file called **configAddress.json** is defined in the **./exo** directory.
And defines all the needed ports. By default : 


```json 
{
	"serverAux --port":{
		"port":"3030",
		"dir":"./plugins"
	},
	"aggregator":{
		"port":"localhost:1883",
		"dir":"./aggregator"
	},
	"plugins":{
		"port":"localhost:1883",
		"dir":"./plugins"
	},
	"server":{
		"port":"3000",
		"dir":"./exo-server"
	}
}
```

if you'd like to change the MQTT broker for example or if some of your ports are busy 
all you have to do is changing the configuration file and restarting the exo instance


Coming back to Exo itself, it may take a while , but if it did not fail you must be able to successfully run :
```ps
py main.py 
```

and you may see : 

<img src="./resources/exo-startup.png" height="400" width="600">

## First Steps 

The first steps to start using Exo is to know your CLI , your best friend : epm. Epm stands for Exo Package Menager, but
it's much more than only it : it's a whole interface system that allows users to manipulate the internal files and 
make changes and monitoring. 

After you startup the system , you can run, in another terminal instance, the command :

```ps
epm --help
```

and see all the current options : 

```
epm --del [mode] [name]                       <- delete items 
epm --w [mode] [name]                         <- make new items 
epm --m [mode]                                <- monitor current items 
epm --notifications                           <- watch live notifications 
epm --notifications:regex [regex]             <- watch current notifications with regex filter 
epm --reports                                 <- watch current reports
epm --reports:regex [filter] [options]        <- watch current reports with regex filter
epm --install [link] [options]                <- install new packages from git repo 
epm --clear [mode]                            <- delete all of a item category 
epm --help                                    <- display this help 

```

In this first tutorial we'll focus on a specific one : **--notifications** and **--notifications:regex [regex]** 
( The other ones will be used as needed in other tutorials ). So, with this command we can watch the topic called
"notifications". This is a special topic because all special behaviors that occurs in the system as a whole will be
published here. For example : when new sensor arrives, new aggregator or plugin is connected. When something goes 
wrong like : a sensor starts behaving unproperly or a plugin or aggregator is disconnected. To use that function you 
just need to do in a terminal : 

```ps
epm --notifications
```



and if you want to filter specific notifications you can use a regex pattern to do it using (example): 

```ps
epm --notifications:regex "[a-z]{0,10}[0-9]"
```

with this you'll be able to watch the system's current health and so on. 




## Using Exo 

To get the best ux with Exo it's strongly recommended reading the tutorials and theorical docs. There you
will find all the resources needed to understand the architecture and basic usage of the system. The tutorials have
an specific order which they were thought to be read. 

* Theory doc 
* Aggregator doc
* Plugins doc
* Schedulers doc
* Resilience doc
* Packages doc 

Those docs includes mock examples and some of the findings of our own experiments with our own applications. If you 
use Exo in some case we encourage you to contribute , specially with documentation ! 



