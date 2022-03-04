import os 
import re
import json

class ConfigGeneral:

    def __init__(self):
        
        return None 

    def check_env_var(self,name:str):
        env_vars = os.environ.items()
        for item in os.environ['PATH'].split(';'):
            i = item.split("\\")
            a = any([re.match(name,y) for y in item.split("\\")])
            if a : 
                return 1 
             
        return 0

    def create_config(self,mqtt_port="localhost:1883",server_main_port="3000",server_aux_port="3030"):

        scheme = json.dumps({
            "mqtt_port" : mqtt_port,
            "server_main_port" : server_main_port ,
            "server_aux_port" : server_aux_port
        })

        e = open("./gui/config.json","w")
        e.write(scheme)
        e.close()        
        
        return 1  
                


class EpmInterface:

    def __init__(self):

        c_path     = os.getcwd().split("\\")
        c_path[-1] = "exo-cli"
        self.epm_path = c_path
        
        return None

    def get_plugins(self):

        command = "epm --m plugins"
        s = subprocess.Popen(command,cwd=self.epm_path,stdout=PIPE, stderr=PIPE)
        
        return s.communicate 

    def create_plugins(self,name,agg,file):

        command = "epm --w plugin {} {} {}".format(name,agg,file)
        s = subprocess.Popen(command,cwd=self.epm_path,stdout=PIPE, stderr=PIPE)

        return s.communicate 

    def create_aggregators(self,name,route):

        command = "epm --w cluster {} {}".format(name,route)
        s = subprocess.Popen(command,cwd=self.epm_path,stdout=PIPE, stderr=PIPE)

        return s.communicate
    
    def get_aggregators(self):

        command = "epm --m cluster"
        s = subprocess.Popen(command,cwd=self.epm_path,stdout=PIPE, stderr=PIPE)

        return s.communicate

    def install_packages(self,link):

        command = "epm --install {} livescript".format(link)
        s = subprocess.Popen(command,cwd=self.epm_path,stdout=PIPE, stderr=PIPE)
        
        return s.communicate
