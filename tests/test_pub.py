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
from colorama import *

ADDRESS = "localhost" 

def on_message(client,userdata,message):
    print("topic :: {}".format(message.topic))
    print("\t"+str(message.payload.decode("utf-8")))

def start_broker():
    print("Starting broker")
    subprocess.Popen(["mosquitto","-p","1883"])
    time.sleep(5)


if __name__ == "__main__":
    start_broker()
    print("Starting pub tests")
    client = mqtt.Client(client_id="sensor moisture teste",clean_session=False)
    client.connect(ADDRESS, 1883, 60)
    client.on_message=on_message
    client.loop_start()
    print("Started publishing at :: sensor/underground/moisture")

    counter = 0 
    
    while True:
        n = random.uniform(8.5,13.6)
        
        client.publish("sensor/aboveground/moisture",str(n))    
        client.publish("sensor/underground/moisture",str(n))
        
        time.sleep(1)
        counter+=1                         

# eof 
