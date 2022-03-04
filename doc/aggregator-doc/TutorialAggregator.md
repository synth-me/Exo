# How to : Aggregators

In this tutorial we'll be seen how to configurate an single aggregator and how it works
in a daily workflow 

# How to start ? 

Everything always starts by using the epm interface, by now we'll be using the command line
interface but soon there'll be a GUI tutorial as well. 
The command to create an aggregator ( after you started your Exo instance ) is :

```ps
epm --w aggregator [name] [route]
```

With that command we can create a single aggregator with the given attriutes .
To begin, we can start by a mock example with the following characteristics :

```ps
epm --w aggregator cluster1 test
```

So as we know by the theorical introduction, this aggregator will listen to the port **sensor/test/#**.
and that's it , our aggregator is already done and runnning ! 

# What if i want to ...

* Delete an aggregator ? 

You just need to :

```ps
epm --del aggregator cluster1 
```

* See the current aggregators ? 

```ps
epm --m aggregator 
```

* Delete them all ? 

```ps
epm --clear aggregator 
```

