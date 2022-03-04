import os 
import sys
import json
from ctypes import * 

class Puppet :

    def __init__(self):
        self.access_puppet = CDLL("./puppet/puppet.dll")
        return None 

    def inspectAggr(self):
        self.access_puppet.inspect(1)
        return None 
    
    def inspectPlugin(self):    
        self.access_puppet.inspect(2)
        return None 

    def inspectScheduler(self):
        self.access_puppet.inspect(3)
        return None 

    def mkAggr(self,name:str,route:str):  
        convert_name  = c_char_p(name.encode("utf-8"))
        convert_route = c_char_p(route.encode("utf-8"))
        self.access_puppet.mkAggr(convert_name,convert_route) 
        return None

    def mkPlugin(self,name:str,routes:list,plugin_name:str):  
#        l = list(map(lambda x : x.encode("utf-8"),routes))
#        array_type          = (c_char_p * len(routes))(*l)
        array_type          = c_char_p(routes.encode("utf-8"))
        convert_name        = c_char_p(name.encode("utf-8"))
        convert_plugin_name = c_char_p(plugin_name.encode("utf-8"))
        self.access_puppet.mkPlugin(convert_name,array_type,convert_plugin_name)
        return None 
    
    def mkScheduler(self,name:str):
        convert_name        = c_char_p(name.encode("utf-8"))
        self.access_puppet.mkScheduler(convert_name) 
        return None 

    def delPlugin(self,name:str): 
        convert_name        = c_char_p(name.encode("utf-8"))
        self.access_puppet.delPlugin(convert_name)
        return None

    def delAggr(self,name:str):
        convert_name        = c_char_p(name.encode("utf-8"))
        self.access_puppet.delAggr(convert_name)
        return None 
    
    def delScheduler(self,name:str):
        convert_name        = c_char_p(name.encode("utf-8"))
        self.access_puppet.delScheduler(convert_name)
        return None 
    
    def monitor(self,f:str,regex:str="default"):
        converted_regex = c_char_p(regex.encode("utf-8"))
        if f == "notifications":
            self.access_puppet.monitor(c_int(1),converted_regex)
        elif f == "reports":
            self.access_puppet.monitor(c_int(2),converted_regex)    
        return None

    def install_package(self,link:str,language:str="livescript"):
        converted_link    = c_char_p(link.encode("utf-8"))
        converted_laguage = c_char_p(language.encode("utf-8"))
        self.access_puppet.install(converted_link,converted_laguage)
        return None 
        
    def clear(self,mode:str):   
        if   mode == "aggregators": self.access_puppet.clear(1)
        elif mode == "plugins":     self.access_puppet.clear(2)
        elif mode == "schedulers":  self.access_puppet.clear(3)
        elif mode == "all":         self.access_puppet.clear(4)
        return None 
