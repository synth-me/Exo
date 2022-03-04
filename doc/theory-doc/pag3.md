# File partition : not as distributed as in soviet union 


## Green threads and config files

Everything in the world is now green, so does threads ! ( always helping the little animals ). The concept of green threads is to
use real processor threds but divided in such a way that it will not push your hardware to it's bad parts. Haskell's runtime will 
use green threads after compiling the files so there should not be thousands of memory leak. 
While using threads it's easy to get brainfuc**ed giving it's natural async nature. In Exo, though, there's another layer of 
complexity given we have lots of configurations files that must be checked and rechecked to make sure nothing is out of control. 
To avoid letting things got wrong lots of times, the IO system in current Exo system is based on streams and lazy evaluation. 


## More names and file blablabla ... 

I'll be direct with you : 
	
* Lazy evaluation 
	* It's the concept of using only the needed part of something, take lists for example : [1...10] in Haskell this is lazy evaluated
	because the memory need to store the list will only be used if the compiler understands that all the numbers will be used, if not 
	it'll be only a potential memory usage. So the same occur with our files, as soon as the actor and supervisor finds a difference 
	they will act without the need to read will the file before ( when possible of course not all cases uses it )

* Streams 
	* Instead of opening, reading and closing a file ( which can lead to deadlock problems ) , we sometimes use streams which is the 
	concept of letting an file opened and keep writing on it. That's specially good when dealing with files that will only be 
	accessed by a single thread and no one more. It's not possible to do it in all cases but it's good for you to know that dumb ! 

Using those concepts allied with green threads we can avoid deadocks, stack overflow and memory leak. This does not mean, though, that
those kind of things do not occur at all those pratices makes them more rare, and by tests we could affair that when some deadlock
occurs usually the thread can try acess in some seconds again and the problem is gone (altough that solution is not the best yet). 


