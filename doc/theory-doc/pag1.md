# Introduction 

## Why Exo's name ?

Exo stands for "Exoskeleton" a analogy of how the architecture works inline with the MQTT protocol. 

## What's Exo ? 

The Exo system is thought to be a superficial operating system that works on the top of MQTT protocol and organizes 
all the boring and repetitive work so that the user only need to worry about it's own criativity ! 
Exo was heavly inspired by other systems such as Erlang VM , ROS and JRuby. All those systems have something 
in common : abstraction layers , such a way that the user can deal with really complex stuff while still 
keeping the language simple and the cognitive overload as low as possible. 


## What about it's DNA ? Haskell 

Exo has a functional DNA. Most of the system is written in Haskell. A purely functional language with a compile time 
type checking system. Altought some of the system is written in another languages, but we mainly choosed Haskell to make 
most of it because we need a safe compiled language to make sure that the data that flows through the 
system wouldn't be affected by undesired side-effects. Haskell is a very performatic language as well and it's runtime
can deal very well with green threads and given we use lots of threads in Exo system that just fits well ! 
The other languages here are used to peripherical structures that Haskell wouldn't perform very well : 

* perl  		: file handling and transpilation  
* python 		: startup file , to boot the system 
* livescript    : run the plugin's scripts 

If you don't know Haskell, we encourage you to try learning it because the Exo's code isn't much idiomatic 
and even a begginer can understand it properly ! 


## Who can use Exo? 

As the same Ruby on Rails did in the begging of the century , our system aims to facilitate the usage of the mqtt protocol 
so it can be used by anyone intrested in IOT development. All the abstraction layers and default options must be enough to 
begin with a full performance development. 
Common users must be able to use Exo as well, given that the package system and the gui will make the user feel like using any 
other OS ! 


## Where does Exo should go ? 

We strongly recommend you to install Exo system in a powerfull server if you're going to use thousands of sensors and plugins
but for small projects and tests any pc will work. The system is smart enough ( thanks to Haskell ) to keep it thread safe and 
will not push your machine to the limit by default. 
The modules will all be started by a single file ( it's plug and play ) and they must be kept as it come so that the binaries. 
and executables won't be messed up.In the future section we will discuss about the future prospects of Exo's architecture modularity 
and there may be good news in the future 
about the module's decentralization, so that this current paragraph may change (keep an eye on it !). 





