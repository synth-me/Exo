import threading 
from colorama import *  
import subprocess
from subprocess import PIPE, check_output
import os 
import time
import sys
import re 
from datetime import datetime
from art import *
from progress.bar import Bar
import pathlib 
from pathlib import Path
import paho.mqtt.client as mqtt
import emoji

def testTree():

    aggr_dir    = {
        "name":"aggregator",
        "dir":["logs"],
        "file":[
            "agg.json",
            "aggregator.exe"   
        ]
    }
    exo_cli_dir = {
        "name":"exo-cli",
        "dir":[],
        "file":[
            "setEnv.pl",
            "epm.exe"
        ]
    }
    exo_ser_dir = {
        "name":"exo-server",
        "dir":[
            "icons",
            "logs",
            "pipelines",
            "resources"
        ],
        "file":[
            "clone.ps1",
            "packages.json",
            "server.exe"
        ]
        
    }
    plugin_dir  = {
        "name":"plugins",
        "dir":[
            "logs",
            "rules",
            "temp",
            "utils"
        ],
        "file":[
            "plugins.exe",
            "serverAux.exe"
        ]
    }
    resil_dir   = {
        "name":"resilience",
        "dir":[
            "models"
        ],
        "file":[
            "main.ls",
            "modelList.json"
        ]
    }
    sched_dir   = {
        "name":"scheduler",
        "dir":[
            "logs"
        ],
        "file":[
            "log.txt",
            "scheduler.json",
            "scheduler.exe"
        ]
    }

    tree = [
        aggr_dir,
        exo_cli_dir ,
        exo_ser_dir ,
        plugin_dir,
        resil_dir,
        sched_dir
    ]


    n = 0 
    for j in tree:

        a = len(j["dir"])
        b = len(j["file"])

        n+=a
        n+=b
    
    bar = Bar(emoji.emojize("Health checking :pill:",use_aliases=True), max=n)
    for k in tree:
        
        dir_format = lambda a : "./{}/{}".format(k["name"],a)
    
        dir_ = all(map(lambda x : Path(dir_format(x)).exists,k["dir"]))
        file_ = all(map(lambda x : Path(dir_format(x)).exists,["file"]))

        if dir_ and file_ :
            for i in range(len(k["dir"])):
                bar.next()

            for i in range(len(k["file"])):
                bar.next()
        else: 
            print(Fore.RED+"Your directory structure is corrupted, try installing Exo again"+Fore.RESET)
            sys.exit()


    print(Fore.GREEN+"\nAll right with your Exo files ... "+Fore.RESET)
    print(Fore.YELLOW+"Initiating bootloader ..."+Fore.RESET)
             

def startModules(config):
    index_B = []
    for i in config.keys() :
        bar = Bar('Initiating {} :: '.format(i), max=8)
        k = "{} {}".format(i,config[i]["port"])
        s = subprocess.Popen(k,cwd=config[i]["dir"],stdout=PIPE, stderr=PIPE)
        
        for ok in range(0,8):
            bar.next()
            time.sleep(1)
        
        if s.poll() is None :
            e = emoji.emojize("{} running ... :runner:".format(i),use_aliases=True)
            log = Fore.GREEN+e+Fore.RESET
        else:
            log = Fore.RED+"Something went wrong with {}".format(i)+Fore.GREEN
            print(log)
            sys.exit()
        
        bar.next()
        bar.finish()
        print(log)

def getPorts():

    return {
        "aggregator":{
            "port":"localhost:1883",
            "dir":"./aggregator"
        },
        "plugins":{
            "port":"localhost:1883",
            "dir":"./plugins"
        },
        "server":{
            "port":"3000",
            "dir":"./exo-server"
        }
    }
    
    
def timer():
    starttime = time.time()
    lasttime = starttime
    lapnum = 1
    time_ = 0 
    while True:
        now = datetime.now()
        laptime = round((time.time() - lasttime), 2)
        totaltime = round((time.time() - starttime), 2)
        time_log = "This instance of EXO have been running for {} hours:minutes:seconds".format(totaltime)
        print(time_log, end="", flush=True)
        print("\r", end="", flush=True)
        time_+=1
        time.sleep(1)
        lasttime = time.time()
        lapnum += 1

def epmOptions():
    table = Fore.GREEN+""" Use the epm command to control the **Exo system **  (at another temrminal)"""+Fore.RESET    
    commands = Fore.CYAN+"""
epm --del [mode] [name]                       <- delete items 
epm --w [mode] [name]                         <- make new items 
epm --m [mode]                                <- monitor current items 
epm --notifications                           <- watch live notifications
epm --notifications:log [filter] [regex/null] <- filter old notification logs 
epm --reports                                 <- watch current reports
epm --reports:log [options]                   <- watch current reports
epm --install [link] [options]                <- install new packages from git repo
epm --clear [mode]                            <- delete all of a item category
epm --help                                    <- display this help

    """
    print(table)
    print(commands)

def testMQTT(var):

    ADDRESS = "localhost" 
    PORT = 1883

    def on_connect(client, userdata, flags, rc):
        e = emoji.emojize("Successfully detected your broker ! :tada: ",use_aliases=True)
        success_log = Fore.GREEN+e+Fore.RESET
        print(success_log)
        var = True             
    
    client = mqtt.Client(client_id="tester-bootloader",clean_session=False)

    try:
        client.connect(ADDRESS, PORT, 60)
        client.on_connect = on_connect
        client.loop_start() 
        return client
    except ConnectionRefusedError :
        print(Fore.RED+"Could not establish connection with broker ... \nmqtt://{}:{}".format(ADDRESS,PORT)+Fore.RESET)
        sys.exit()

def initiate():
    art_1=text2art("--EXO--")
    print(art_1)
    epmOptions()
    

def starts(v):
    CONNECTION = False
    
    t = testMQTT(CONNECTION)
    
    t.disconnect()
    t.loop_stop()
    
    testTree()
    startModules(getPorts())
    v[0] = 1
    initiate()
    

# eof 
