# Exo Modules-Architecture

## Let's talk about executables ... 

The exo system itself is made out of some executables that perform tasks in their specific directories ( 
your Genius author ! now tell me that the sky is blue ...).
To be more specific , those are the following executables and their directories :

	* Aggregator in exo/aggregatotr	
	* PLugins in exo/plugins
	* serverAux in exo/plugins
	* Schedulers in exo/schedulers
	* Resilience in exo/resilience 
	* Server in exo/exo-server
	* Epm in exo/exo-cli	

and the startup.exe in the upper directory of exo which is not considered a foundation module. 
All those executables are installed by Exo and will be spawned when the startup file tells it to . 
Each of them perform a task whithin the OS using the system's configurations files. 
The **Aggregator**, **Plugins** and **Schedulers** are the most important ones and they're the ones 
that makes most part of the information's flow control. **Resilience** is the AI module, which is basically
an experiment and makes this module very beta yet. Athough it's very important for the current purpose of 
the experiments that will be shown here. **serverAux** is a parallel http server to make js plugins execution 
faster and more direct. The scripts will be executed outside the main process which allows for more safety and
speed. The **Server** and **Epm** modules talks to each other directly. The first one creates an http interface 
to the second to access the internal configuration files, so that fundamental changes can be done without compromising 
the integrity of those files given that the access is controlled by that interface. 
The following diagram may give you a a spacial sense of how all those modules communicate with each other


<img src="./resources/full-scheme.png">


in this scheme : 
* Sensors : S
* Aggregators : A 
* Plugins : P
* serverAux is the js interpreter 
* Schedulers : Sch
* Intf : Interface , where goes the reports 
We'll be diving deeper into those specific schemes when getting into specific chapters of each
module, by now you can see that everything is interconnected and everything has a reason !	
That's all ! All the theory went out now, we hope you could understand the basics of Exo OS and now you're able 
to pass to another directories and watch the specificities about the foundation modules functionalities. 

