# Be like water my friend 

One of the main spots of the exo system is it's resilience capababilities. This is everywhere but more specifically 
in this specific point. Imagining that this kind of system is designed to be online for days and days and rarely be 
turned off then it is good to have a tool that will help us spot problems and solve them. In this case, a problem we'll try 
to solve is the problem of damaged sensors.

# The study case  

To illustrate the problem imagine we're processing various kinds of sensors like the following mock data :  

```

a : 1
b : 2 
c : 3

```

and then the sensor **b** starts publishing a random nonsense data :


```

a : 1
b : jfskh74
c : 3

```

that probably means we have a hardware problem with the **b** sensor. If this problem have been persisting for some hours all our 
database is now compromised, to be clear : **poisoned**. Our plugins have been processing trash for a long period of time.
To solve that kind of occurence we thought in creating a system that could transform a trash data into new good data again ! 


# Clustering and Math 


Mathematically speaking we all our data that comes from the sensors are a array of float vectors. Let's continue with our last example:


```json

{
	"name_agg":"cluster1",
	"current_data":[
		["a",1],
		["b",2],
		["c",3]
	]
}

```

if we extract only the values form the sensors we'd have : 


```hs
let vec = [1,2,3]
```

The same can be done to the trash data as well 


```hs
let vec_trash = [1,jfskh74,3]
```

How to rebuild that information ? : Historical data ! Given that we've been processing data for a **T** period of time before the sensor
stopped working then we can train an IA model to recognize contextual data, like the following : 

```hs

[3,4,5]
[6,7,8]
[9,10,11]

``` 

So imagine a generic math model could be feed with that data , then our model could predict something that as **formation rule** for
our data : 


```hs
formation :: Int -> [Int]
formation x = [x,x+1,x+2]
```

and then if we now have a trash data, we'll only need the first element to predict our data : 

```hs
[1,jfskh74,3] -> [1,z,3] -> [1,2,3]
```


# Otherwise, not everything is so simple in the real world 


Of course those were mock examples. In the world we'd need at least two more things to actually discover our hidden data :

* Clustering 

In our mock example, the clustering algorithm wasnt needed because we only had few data strcutures. In real data, otherwise, various other factors
influences the information that comes into play. The current research case, and for most part of other contexts, we'll be using the time as a cluster
criteria. So all clusters will be divide depending on their current point in the day time. We'll have 24 cluster for each new model and each cluster with 
inifinite number of data.
The **k-means** algorithm we'll be using then needs to correctly identify the cluster the corrupted information belongs to, so that's our objective.


* Substitution 

After we figured out which cluster does one the information belongs to, we need to actually rebuild it. Let's see a simple mock example with the following clusters :


```

a : [0,2],[4,6] 
b : [1,3],[5,7]
c : [-1,-2],[-3,-4]

```

Here each of the letters denotes a range of time in the day. 
So lets consider a corrupted vector at period of time **a** ( the model would guess it).

```hs
let v = [4.25,x]
```

Now, how we proceed ? we need to find the formation rule, to do that. If we look and imagine the formation rule 
as : 

```hs

formation :: Int -> [Int]
formation x = [x,x+2]

```

Then the strict answer to the vector's information lack (x) is **6.5**. We cannot guess such a precise value because 
we won't be processing formational rules (because it's not needed), but vector proximity using the cos-similarity algorithm. 
After doing so we find that the closet vector will be **[4,6]** and we consider it to rebuild our trash one :


```hs
[4.25,x] 
[4,6]
``` 

and as result we substitute our **x** by **6** and we get a vector of **[4.25,6]**. In this case we got a **4.16%** of error based on our expectations, 
but it won't impact the rest of the system as whole given we've been dealing with lots and lots of data and **4.16%** of error is a good margin.


# System Integration 

<img src="./resources/resilience-scheme.png">

To actually use **Resilience** you don't need special configurations or anything. That's because there's always an model associated to each aggregator.
If a new aggregator is added to the system, the Exo will understand it and already start collecting information and creating a database. Thre're two ways
of activating the rebuilding mode : 

* Null information

When a sensor starts publising **0** as it's value or **null** the system will atumatically starts to rebuild that information for you. So be aware to not
let any of your sensors use **0** or **null** as a accepted value. 


* Plugins 

There's a global function that can be accessed using your plugin called **REBUILD** which will rebuild one specific information send to the your IA. This 
is much easier to be used and you can make it customized for specific values that the default structures cannot predict. For example : 


```ls

test = (x) ->
	x 
	|> FilterSensorData
	|> -> if any (>1.5) x   
			then REBULD(x)
			else x

```


This simple function for example may rebuild the **x** data when any of it's members have a value smaller then **1.5 **.
It's important noticing that when the AI is called it publishes a notification in the **notification** topic warning the user about the corrupted sensor. So 
you can monitor the actions of your customized trigger function with : 

```ps
epm --reports
epm --notifications 
```


# Warnings 


All of this is very cool and integrated out of the box and manually with the system, but this kind of information rebuilding have a purpose. The same way 
we can rebuild a image out of broken camera, we do so because the camera may be fixed in the future, the same here : the sensor must be fixed. We can think
of the precision of the system as time inverse formula : 


```hs

precision d t = d/t 

```

Where **d** is your database lenght and **t** is the current time passed. Don't let the **Resilience** working forever, otherwise we'll end up having what we've been
trying to avoid : poisoned database with bad formed information. To avoid this, you can implement ( and we strongly recommend you to do so ) a redundant sensor system
where each of them have their counterparts in case of bad function and then **Resilience** must only work for a brief period of time ( some hours ) correcting small amount of errors.
