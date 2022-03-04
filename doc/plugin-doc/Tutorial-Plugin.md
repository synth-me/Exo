# Let's do it

To create a new plugin we just need to use our best friend epm : 

```ps
epm --w plugin [name] [script] [route]
```

In this case we can mock on up using the following instructions : 

```ps
epm --w plugin module1 test_one test
```

If you followed up the last tutorial from aggreagtors you know we created
one aggregator that will publish on the topic **agg/test-output** the joined
information from the sensors. This plugin, then, will listen to this aggregator 
using a file called **test_one**. In this case we will manually insert the plugin source
code. You just need to insert the source file in the folder **./exo/plugins/rules**. The source
code is the following :

```js

function main(){
	EXPORT(INPT);
};

main();

```
Which is a basic plugin written in JS. Save it in a .js file and put in the right directory.
**If manually putting the plugin inside rule's folder you must already compile it to JS yourself, the pipelines only work with downloaded plugins** 
Then we can see our plugin with the command :  

```ps
epm --m plugin
```

or , if you want, to delete it or delete all plugins:

```ps
epm --del plugin module1 
epm --clear plugin 
```

To test if everything is ok you can navigate to the **./examples** folder and run a script called "test.py" as the 
following example : 

```ps
py test.py localhost:1883 
```

Here we'll be using our local broker but you can use any broker you'd like to.  
If we did everyhting ok , we're able to see the plugin's results using the command : 

```ps
epm --reports 
```

If you'd to post process that data you can pass regex args and print on specific reports we can filter them by 
passing an regex pattern to match them.

```ps
epm --reports:regex [a-z]
```

