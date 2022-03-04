import os
from grip import serve

def open_read(path):
    o = open(path).read()
    return o

l = [
   "./cover.md",
   "./Index.md",
   "./GettingStarted.md",
   "./theory-doc/pag0.md",
   "./theory-doc/pag1.md",
   "./theory-doc/pag2.md",
   "./theory-doc/pag3.md",
   "./theory-doc/pag4.md",
   "./aggregator-doc/Introduction-Aggregator.md",
   "./aggregator-doc/TutorialAggregator.md",
   "./plugin-doc/Introduction-PLugin.md",
   "./plugin-doc/Tutorial-Plugin.md",
   "./resilience-doc/Introduction-Resilience.md",
   "./packages-doc/Introduction-Packages.md",
   "./packages-doc/Tutorial-Packages.md"
]



nl = "\n".join(list(map(open_read,l)))

on = open("./doc.md","w")
on.write(nl)
on.close()



serve(path="./doc.md")

# eof
