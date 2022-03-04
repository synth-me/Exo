# Our purpose 

The Exo system is not made to be **the best, ready to production** OS to MQTT but rather a scientific experiment. 
Here we want to stabilish some concepts that we think are great to advance the world of MQTT and IOT as whole. 
As the linux world did years and years ago, disrupting the ideia of a open source OS we want to do here for IOT. 
Not really defining that THIS system will be used by everybody from now but that the philosophy embody here will 
serve as a kernel to the future of new OS systems based on it. 

## Current attributes 

The current Exo system is based on a research in agricultural sensors, and the bottom-up architecture strcuture is 
based on the problems derived out of this specific spectrum of problems derived from the agricultural sensors integration
which means that it does not mean the Exo will perfectly fit all other IOT world's problem. Altough, as sais by DHH 
once the good frameworks are extracted out of real constrained applications. As ruby on rails emerged from a chat 
app the same is Exo emerging from a agricultural-driven IOT system and then expanding. 

## Our Objectives 

The objectives aimed with this system is to persue a better flexibility and usability while programming data 
processing pipelines in IOT world , wih a safe and stright forward system. It's being years since IOT is a real 
thing in the market but no solution like that have ever been done and now we have the opportunity to jump into it 
and try to start a new line of IOT OS that may help all developers that would like to contribute to the IOT world. 
From the foundations we can stabilish that the main objectives are : 

	* Flexibility
	* Usability 
	* Openess 
	* Resilience 
	* Reproducibility

### Flexibility

Our systems aims to be used in different contexts and plataforms and operates similarly in all of them. In the IOT
world we still have lots of close softwares that do not fit the rest of ohters ecosystem. Exo, altough, is very 
easy to install and use in any platform and we imagine that this must be a axiom in the current IOT world. 

### Usability 

In the Exo system's internal system, the boring parts are abstracted so that the user don't need to deal with 
the bad part of stablishing topics and routes and all blablabla. The user can, with two clicks, makes a whole
system works perfectly without the need to touch any code using the GUI and the package's links. That's another point
that a lot of IOT world lacks of, and that we want to bring back.

### Openess

Deriving from the MQTT philosophy of publicity , we designed our system in a way that all information is avaible 
for any agent connected so that everything can inspected, read and processed freely. That's good because lots of 
other OS do not allow the access of certain raw information, or at least made very difficult to find and inspect them.


### Resilience 

That attribute come directly from the Erlang's , and more recently Elixir's, philosophy of a VM with various fail 
tolerant systems. The case with Erlang as very similar to our IOT one : a crash on one point must not compromise the 
rest of the system. That's the case here , to that we use the two technics : AI and functional programming. 
Using Haskell as the foundation of the system we can garanty a safe source code. And using the resilience AI cluster
we can make sure some of the data won't be lost the our system will keep running even if it's little injured.


### Reproducibility

Last but not least the reproducibility. Here we return to the packages. That's because other reactive system like ROS
makes it very difficult to install specific packages and drivers for each new component ( because dealing with robots 
is more complex) but do not makes it impossible. In our system the packages are very easy to install and very flexibly 
in terms of languages and usability. The reproducibility is done as easy as it seems given we're using well stabilished 
tools like git, github and json. 


## Finals thoughts

As said before this system is a just a beggining foundation of a hidden philosophy that it embodies. We strongly hope new systems
will emerge out of this one and shiny even more fitting different problems using different tools and architectures. By now we will
keep improving our researches. 

Keep an eye on it ! 


