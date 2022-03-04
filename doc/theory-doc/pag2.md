# Exo: the movie,starring actor oriented programming 


## What's on earth is "Actor oriented programming " (AOP) ? 


Here the magic begins ! The foundation rock of the exo system is the so-called "Actor oriented programming" which is a programming
paradigm that have it's roots in the late 70's with the researchs by the Erlang creators in Ericsson labs. 
This programming paradigm was basically made to deal with multiple threads performing very different tasks and their communication
system. Lots of languages have libraries to deal with actor based system but Haskell does not have any decent and maintained one. 
In exo system we used programming patterns to deal with those actors and by now we haven't extracted the library out of it yet. 
Here you'll find that each module have a similar strcuture that follows the principles of AOP. 


## Ok, but how does that work ? 

The current paradigm have no official stablished foundations and each author applies the abstract concepts to it's own interpretation
and programming language specificities. In this case we use a pattern here named "Supervisor-Actor". 
The following definitions are applied : 

* Supervisor 
	* It's a main thread a module, it's keeping observing and reacting to specific tasks , most of them are IO operations 
	such as file changes, and for each change there's basically 2 operations : IO or spawning. 
	In Exo , the supervisor does not have the power to kill child threads only to spawn them. So while the supervisor is 
	watching a file it can see if the there's a need to spawn new threads or make some IO operation.
* Actor
	* The actors are independent threads spawned by the supervisor that have it's own life cycle. The actor can perform 2 actions
	as well : IO or killing. The Actor's divison is 2 too : head and body. The head is the part of the thread that keeps watching 
	an specific file and waits for changes, the body is the the part that is always processing data. If a changes occurs in the file
	the head will react and will choose to kill it's own or to keep processing data. 

Example : 
	Let's say we have **file1.json** and we'll use AOP architecture to perform an action on it : 
file1.txt has : 
```json
{ "a":[1] } 
```
Our supervisor will watch it and create an actor that prints the number 1:
```
1
1
...
``` 
But when we change the file to :
```json
{ "a":[1,2] } 
```
then : 
```
1
2
1
2 
...
```

Now the supervisor will create a new thread that prints the number 2. What if we do :

```json
{ "a":[1] } 
```	

Now the "number 1 thread" will check this file and understand that it's been deleted so we now will only see : 

```
1
1
1 
...
```

This general architecture is found in all four foundation modules : plugins, aggregators , schedulers and Resilience.
In all those modules the flexibility of AOP is shown by the fact that supervisors may spawn new actors and the actors may kill
shut down themselves based on IO operations controlled by configuration files. If those files changes they can rapidly change their 
states and starts processing data in a different way !
This was a introductions to this concept, it's alright if you didn't get it at first the next pags and chapters will come back to 
this frequently and you may understand it better.


