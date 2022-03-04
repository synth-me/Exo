# Let's get our hands .. not dirty at all, that's very easy ! 

This will be a very easy tutorial. As said in the other tutorials, let's first run our modules : 

```ps
startup 
``` 

after you saw that nothing crashed, we go to another terminal and : 

```ps
epm --m plugin
```

let's say we say we saw a clear plugin's container , if not you clean with the command : 

```ps
epm --clear plugin
```

After that we're good to go and see the package being installed with the command : 

```ps
epm --install https://github.com/synth-me/ExoPackager livescript
```

in this case you see we passed the parameter **livescript** meaning the livescript compiler must be used 
to create a readable plugin. This may take a while, but after it all you should be able to see your reports
being logged with the command : 

```ps
epm --reports 
```

and we're good, now you know how to install packages ! 

