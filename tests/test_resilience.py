import os 
import json 
import typing 
import subprocess
from typing import *
import random
import requests 
import paho.mqtt.client as mqtt
import time
import random 

ADDRESS = "localhost"
ACTUAL_STD_INFO = {}


def on_message(client,userdata,message):
    print("----")
    info = json.loads(str(message.payload.decode("utf-8")))
    try:
        j = [i[1] for i in ACTUAL_STD_INFO["moment_data"]]
    
        km = list(zip(info,j))

        lk = [(x/y)*100 for x, y in km]
        m = max(lk)

        print(info)
        print(j)
        
        print("----")
    except:
        pass

def start_broker():
    print("Starting broker")
    subprocess.Popen(["mosquitto","-p","1883"])
    time.sleep(5)

def information(mode,info):
    if mode == "corrupted":
        coeficient = 1.7*info
    else:
        coeficient = 2.2*info
                
    x = {
        "mode":mode,
        "name_log":"teste",
        "moment_data":[
            ["teste1",info*1.1],
            ["teste2",coeficient],
            ["teste3",info*3.3],
            ["teste4",info*4.4]
        ]
    }

    return x 

if __name__ == "__main__":
    start_broker()
    print("Starting pub tests")
    client = mqtt.Client(client_id="sensor moisture teste",clean_session=False)
    client.connect(ADDRESS, 1883, 60)
    client.on_message=on_message
    client.subscribe("agg/underground-output")
    client.loop_start()
    counter = 1
    while True :
        print("Publishing ...")
        mode = "corrupted"
        i = information(mode,counter)
        ACTUAL_STD_INFO = i
        p = json.dumps(i)
        client.publish("notification/resilience/underground",p) 
        time.sleep(1)
        counter += 1 


