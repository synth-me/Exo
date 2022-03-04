# Introduction to Aggregators 

## What's an aggregator ? What does that aggregates ? I need answers, now ! 

So, the Exo OS is thought to be a down-top approach to solving IOT problems. To do that we need abstraction layers
between the iot hardware components and our software processing units. The first layer of abstraction here is 
the **Aggregator**. 
As the name suggests the aggregator joins informations from the sensors into a specific data structure. 
In the exo system the aggregator will make use the MQTT topic's patterns to specifiy the sensors you want to listen
to. An aggregator configuration file is basically as following : 

```json
{ "name_agg":"A","route":"B" }
```

This json describes a aggregator of name **A** that listen to **B**. Here, though, the listening occurs slightly 
differently from direct communcation because we need flexibility, so the listening occurs on a range of ports 
delimited by the following pattern : "sensor/B/X" where B is the current route attribute and X is the generic 
sensor name you'd like to use. In this case we case we can see some well-formed sensor's topics as the following : 

```
sensor/B/moisture-1 
sensor/B/moisture-2
sensor/B/temperature
``` 

With this done, your aggregator is able to generate a well formed data structure known as GenericAggregator as following

```json
{
	"name_agg":"A",
	"current_data":[
		["sensor/B/moisture-1",1],
		["sensor/B/moisture-2",2]
	]

}
```

This data structure is very simple but powerfull enough to export all the information that need to be processed by 
our post-processing plugins. We have the current aggregator name and the sensor's it has been listening to recently. 
A good part is that given we're using a pattern to define our listening topic there're no limits to the amount of 
sensors that can be connected to the aggregator nor specific ones. For example, if we suddenly starts publishing  
a new information on the topic **sensor/B/temperature-2** the aggregator will recognize it and just add this to the
generic output structure:

```json
{
	"name_agg":"A",
	"current_data":[
		["sensor/B/moisture-1",1],
		["sensor/B/moisture-2",2],
		["sensor/B/temperature-2",3]
	]

}
```

and the aggregator is good wiht it, no problems at all. As seen before in the general theory documentation, this is 
a configuration modification automatically done by the system so a notification will be published in the **notification**
topic as the following : "[New sensor sensor/B/temperature-2 at time T]" ( with the time T being the current date). 
It's good to point that aggregators will always publish the result information from the processing and concatenation 7
of the sensor's information in a specific topic pattern the same as **agg/B-output**. 
If you're a visual person, the following scheme maybe be clarifying to you : 

<img src="./resources/aggregator-scheme.png">
