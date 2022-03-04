import json
import tkinter as tk
from tkinter import * 
from tkinter import ttk
import threading 
import requests 
import time 
import os
import gui.tools
from gui.tools import *
import startup
from PIL import Image,ImageTk
import puppet.ExoAPI 
from puppet.ExoAPI import Puppet
import subprocess
from subprocess import PIPE, check_output
import paho.mqtt.client as mqtt


GLOBAL_CATALOG = {
  "terminal":"",
  "file":""  
}

global COUNTER_Y
COUNTER_Y = [0]
COUNTER_Y[0] = 0 

global COUNTER_X
COUNTER_X = [0]
COUNTER_X[0] = 0

global GeneralPlg
GeneralPlg = {}

puppet = Puppet()    

def notifications_screen():
    
    notification_window = tk.Toplevel()
    notification_label = tk.Label(notification_window,text="Current notifications",bg="#2E3440",fg="#A3BE8C")
    sub_frame = tk.Frame(notification_window)
    
    regex_area = tk.Entry(sub_frame,bg="#2E3440",fg="#A3BE8C")
    search_btn = tk.Button(sub_frame,bg="#2E3440",fg="#A3BE8C",text="filter",borderwidth=0,activebackground="#A3BE8C")

    log_area   = tk.Text(notification_window,bg="#2E3440",fg="#A3BE8C")
    
    def test(log_area): 
        
        def on_message(client,userdata,message):
            msg = str(message.payload.decode("utf-8"))
            print("receving ...")
            log_area.insert("1.0",msg + "\n")
        
        client = mqtt.Client(client_id="notification_agent",clean_session=False)
        client.connect("localhost", 1883, 60)
        client.on_message=on_message
        client.subscribe("notifications")
        client.subscribe("notification")
        client.loop_start()
    
    threading.Thread(target=lambda : test(log_area) ).start()
    
    regex_area.pack(fill=BOTH)
    search_btn.pack(fill=BOTH)

    notification_label.pack(expand=True,fill=BOTH)
    log_area.pack(expand=True,fill=BOTH)
    sub_frame.pack(expand=True,fill=BOTH)
        
    return 0

def reports_screen():
    
    reports_window = tk.Toplevel()
    reports_label = tk.Label(reports_window,text="Current reports",bg="#2E3440",fg="#A3BE8C")
    sub_frame = tk.Frame(reports_window)

    regex_area = tk.Entry(sub_frame,bg="#2E3440",fg="#A3BE8C")
    search_btn = tk.Button(sub_frame,bg="#2E3440",fg="#A3BE8C",text="filter",borderwidth=0,activebackground="#A3BE8C")

    log_area   = tk.Text(reports_window,bg="#2E3440",fg="#A3BE8C")

    def test(log_area):

        def on_message(client,userdata,message):
            msg = str(message.payload.decode("utf-8"))
            log_area.insert(END,msg + "\n")
        
        client = mqtt.Client(client_id="report_agent",clean_session=False)
        client.connect("localhost", 1883, 60)
        client.on_message=on_message
        client.subscribe("+/output")
        client.loop_start()
    
    threading.Thread(target=lambda : test(log_area)).start()
    
    regex_area.pack(fill=BOTH)
    search_btn.pack(fill=BOTH)

    reports_label.pack(expand=True,fill=BOTH)
    log_area.pack(expand=True,fill=BOTH)
    sub_frame.pack(expand=True,fill=BOTH)
    
    return 0

def terminal_screen():
    
    return 0

def package_screen():   

    package_get = tk.Toplevel()

    link_label    = tk.Label(package_get,text="Insert your link :: ")
    link_insert   = tk.Entry(package_get)
    link_progress = ttk.Progressbar(package_get,length=100,orient='horizontal',mode = 'determinate')

    def progress_start():
        v = 10
        link_label["text"] = "Downloading ..."
        const = link_progress["length"]/v
        j = 0 
        for i in range(int(link_progress["length"]/v)): 
            link_progress["value"] += const
            j += const
            print(j)
            time.sleep(1)
        if j >= link_progress["length"]:
            link_label["text"] = "Installed !"
            time.sleep(2)
            package_get.destroy()
            
    link_download = tk.Button(package_get,text="install",bg="#A3BE8C",command=lambda : threading.Thread(target=progress_start).start())
    
    link_label.pack(fill=BOTH,expand=True)
    link_insert.pack(fill=BOTH,expand=True)
    link_progress.pack(fill=BOTH,expand=True)
    link_download.pack(fill=BOTH,expand=True)
    
def plugin_create(f):

    plugin_creator = tk.Toplevel()

    plugin_name = tk.Label(plugin_creator,text="Name")
    plugin_agg  = tk.Label(plugin_creator,text="aggregators")
    plugin_file = tk.Label(plugin_creator,text="Source File")

    plugin_name_entry = tk.Entry(plugin_creator)
    plugin_agg_entry  = tk.Entry(plugin_creator)
    plugin_file_entry = tk.Entry(plugin_creator)
    
    def add_destroy():
    
        name   = plugin_name_entry.get()
        routes = plugin_agg_entry.get()
        file   = plugin_file_entry.get()

        f(name,routes,file)
        plugin_creator.destroy()
            
        
    create_btn = tk.Button(plugin_creator,text="Create",bg="#A3BE8C",command=add_destroy)
    
    plugin_name.grid(row=0,column=0)
    plugin_name_entry.grid(row=0,column=1)
    plugin_agg.grid(row=1,column=0)
    plugin_agg_entry.grid(row=1,column=1)
    plugin_file.grid(row=2,column=0)
    plugin_file_entry.grid(row=2,column=1)
    create_btn.grid(row=3,column=0,columnspan=3)

    return 0

def aggregator_create():

    aggregator_creator = tk.Toplevel()

    aggregator_name = tk.Label(aggregator_creator,text="Aggregator name")
    aggregator_name_entry = tk.Entry(aggregator_creator)

    aggregator_route = tk.Label(aggregator_creator,text="Aggregator route")
    aggregator_route_entry = tk.Entry(aggregator_creator)
    
    def create():
        aggr_name  = aggregator_name_entry.get()
        aggr_route = aggregator_route_entry.get()
        puppet.mkAggr(aggr_name,aggr_route)

    aggregator_set = tk.Button(aggregator_creator,text="Create",bg="#A3BE8C",command=create )
    
    aggregator_name.grid(row=0,column=0)
    aggregator_name_entry.grid(row=0,column=1)
    aggregator_route.grid(row=1,column=0)
    aggregator_route_entry.grid(row=1,column=1)

    aggregator_set.grid(row=2,column=0,columnspan=3)

    return 0

def scheduler_create():

    scheduler_creator = tk.Toplevel()

    return 0


def desktop(window):

    def plugin_icon(window_f,name,routes,file,show=0):
        
        plugin_frame = tk.Frame(window_f)
        plugin_frame.configure(background="#3B4252")        

        global selected_plugin
        selected_plugin = [0]

        def delete_confirmation(pl):

            confirmation = tk.Toplevel()

            asst = tk.Label(confirmation,text="Are you sure you want to delete {} ?")

            def d():
                puppet.delPlugin(name)
                pl.destroy()
                confirmation.destroy()
               
            conf = tk.Button(confirmation,bg="#A3BE8C",text="Yes",command=d )
            neg  = tk.Button(confirmation,bg="#BF616A",text="No",command=lambda : confirmation.destroy())
            
            asst.pack(side=TOP,expand=True)
            conf.pack(fill=X,expand=True)
            neg.pack(fill=X,expand=True)

        def inspect_plugin():

            inspect = tk.Toplevel()
            
            name_module = name
            script_path = GeneralPlg[name]["script_path"]
            routes      = GeneralPlg[name]["routes"]
            
            name_module_label = tk.Label(inspect,text="module name :: {}".format(name_module))
            script_path_label = tk.Label(inspect,text="script name :: {}".format(script_path))
            routes_label      = tk.Label(inspect,text="listening to :: {}".format(routes))

            name_module_label.pack(side=TOP,expand=True)
            script_path_label.pack(fill=X,expand=True) 
            routes_label.pack(fill=X,expand=True)          
            

        m = Menu(plugin_frame, tearoff = 0)
        m.add_command(label ="Delete",command=lambda : delete_confirmation(selected_plugin[-1])   )  
        
        def wrapper(clickable):
            
            def do_popup(event):
                try:
                    selected_plugin.append(clickable)
                    m.tk_popup(event.x_root, event.y_root)
                finally:
                    m.grab_release()

            return do_popup
        
        plugin_clickable = tk.Label(plugin_frame,text="plugin",image=GLOBAL_CATALOG["file"],borderwidth=0)
        pop = wrapper(plugin_frame)
        plugin_clickable.bind("<Button-3>", pop )
        
        name_plugin = tk.Label(plugin_frame,text=name,bg="#3B4252",fg="white")
        m.add_command(label ="Inspect",command=lambda : inspect_plugin() )
        
        plugin_clickable.pack()
        name_plugin.pack(expand=True)
                         
        
        if COUNTER_X[0] >= 5 :
            COUNTER_X[0]  = 1 
            COUNTER_Y[0] += 1 
        else:
            COUNTER_X[0] += 1
        
        if show == 0 :
            print(name)
            print(routes)
            print(file)
            puppet.mkPlugin(name,routes,file)
            
        plugin_frame.grid(row=COUNTER_X[0],column=COUNTER_Y[0],padx = 10, pady = 20)

    desktop_frame = tk.Frame(window)
    desktop_frame.configure(background="#3B4252")
    

    m = Menu(desktop_frame, tearoff = 0)
    
    def do_popup(event):
        try:
            m.tk_popup(event.x_root, event.y_root)
        finally:
            m.grab_release()
    
    desktop_frame.bind("<Button-3>",do_popup)

    def insert_icon():
        f = lambda x,y,z: plugin_icon(desktop_frame,x,y,z)
        plugin_create(f)

    
    m.add_command(label ="New plugin",command=insert_icon)
    m.add_command(label ="New aggregator",command=aggregator_create)
    m.add_command(label ="New scheduler",command=scheduler_create)

    s = subprocess.Popen("epm --m plugin",cwd="./exo-cli",stdout=PIPE, stderr=PIPE)
    
    output, err = s.communicate()

    def rreplace(s, old, new):
        return (s[::-1].replace(old[::-1],new[::-1], 1))[::-1]
    
    try:
        output_json = json.loads(output)
    except:
        output = output.decode("utf-8")
        output = output.replace('"','',1)
        output = rreplace(output,'"','')
        output_json = json.loads(output)
        
        for i in output_json :
            plugin_icon(desktop_frame,i["name_module"],"","",1)
            GeneralPlg[i["name_module"]] = {
                "routes":i["agg_route"],
                "script_path":i["script_path"]
            }

            
    desktop_frame.pack(fill=BOTH,expand=True)
    
    return 0

def top_bar(window):

    menubar = Menu(window)
    file = Menu(menubar, tearoff = 0)
    menubar.add_command(label ='config', command=lambda : config_screen(window))
    
    window.config(menu=menubar)
    
    return 0


def down_bar(window):

    down_frame = tk.Frame(window)
    down_frame.configure(background="#2E3440")

    sub_down_frame = tk.Frame(down_frame)
    sub_down_frame.configure(background="#2E3440")

    button_notification = tk.Button(sub_down_frame,text="notifications",borderwidth=0,bg="#D8DEE9",fg="#2E3440",activebackground="#2E3440",command=notifications_screen)

    button_notification.bind("<Enter>", lambda e: button_notification.config(bg='#2E3440',fg="#D8DEE9"))
    button_notification.bind("<Leave>", lambda e: button_notification.config(bg='#D8DEE9',fg="#2E3440"))

    button_reports      = tk.Button(sub_down_frame,text="reports",borderwidth=0,bg="#D8DEE9",fg="#2E3440"      ,activebackground="#2E3440",command=reports_screen)

    button_reports.bind("<Enter>", lambda e: button_reports.config(bg='#2E3440',fg="#D8DEE9"))
    button_reports.bind("<Leave>", lambda e: button_reports.config(bg='#D8DEE9',fg="#2E3440"))
    
    button_terminal     = tk.Button(sub_down_frame,text="terminal",borderwidth=0,bg="#D8DEE9",fg="#2E3440"     ,activebackground="#2E3440",command=terminal_screen)

    button_terminal.bind("<Enter>", lambda e: button_terminal.config(bg='#2E3440',fg="#D8DEE9"))
    button_terminal.bind("<Leave>", lambda e: button_terminal.config(bg='#D8DEE9',fg="#2E3440"))    
    
    button_packages     = tk.Button(sub_down_frame,text="packages",borderwidth=0,bg="#D8DEE9",fg="#2E3440"     ,activebackground="#2E3440",command=package_screen)

    button_packages.bind("<Enter>", lambda e: button_packages.config(bg='#2E3440',fg="#D8DEE9"))
    button_packages.bind("<Leave>", lambda e: button_packages.config(bg='#D8DEE9',fg="#2E3440")) 
    
    button_monitor      = tk.Button(sub_down_frame,text="monitor",borderwidth=0,bg="#D8DEE9",fg="#2E3440"      ,activebackground="#2E3440")

    button_monitor.bind("<Enter>", lambda e: button_monitor.config(bg='#2E3440',fg="#D8DEE9"))
    button_monitor.bind("<Leave>", lambda e: button_monitor.config(bg='#D8DEE9',fg="#2E3440"))
    
      
    button_notification.pack(side=LEFT,fill=X,expand=True)
    button_reports.pack(side=LEFT,fill=X,expand=True)
    button_terminal.pack(side=LEFT,fill=X,expand=True)
    button_packages.pack(side=LEFT,fill=X,expand=True)
    button_monitor.pack(side=LEFT,fill=X,expand=True)
    
    sub_down_frame.place(anchor=CENTER)
    sub_down_frame.pack()

    down_frame.pack(fill=BOTH,side=BOTTOM)

    return 0

def main_screen(window):
    
    top_bar(window)
    desktop(window)
    down_bar(window)

def boot_screen():  

    boot_window = tk.Tk()
    boot_window.title("Boot screen")
    boot_window.geometry("600x400")

    variables = [
        "aggregators",
        "plugins",
        "serverAux",
        "serverMain"
    ]
    
    boot_logging = tk.Label(boot_window)
    progress = ttk.Progressbar(boot_window,length=100,orient='horizontal',mode = 'determinate')

    def log_progress():
        const = progress["length"]/len(variables)
        for i in variables :
            log = "Installing :: {}".format(i)
            boot_logging["text"] = log
            progress["value"] += const
            time.sleep(2)

        boot_window.destroy()

    threading.Thread(target=log_progress).start()


    boot_logging.pack(side=TOP,pady=20)
    progress.pack()

    boot_window.mainloop()
    
    
    return 0     

def config_screen(window):

    window_config = tk.Toplevel(window)

    logo   = tk.Label(window_config,image=GLOBAL_CATALOG["logo"])

    spotted_label = tk.Label(window_config,text="First initialization, configure the ports :: ")
    
    serverAux_default = tk.StringVar()
    serverAux_default.set("3030")
    serverAux_title  = tk.Label(window_config,text="Server aux port :: ")
    serverAux_label  = tk.Entry(window_config,textvariable=serverAux_default)

    serverMain_default = tk.StringVar()
    serverMain_default.set("3000")
    serverMain_title  = tk.Label(window_config,text="Server main port :: ")
    serverMain_label = tk.Entry(window_config,textvariable=serverMain_default)

    mqtt_default = tk.StringVar()
    mqtt_default.set("localhost:1883")
    mqtt_title  = tk.Label(window_config,text="Broker port :: ")
    mqtt_label = tk.Entry(window_config,textvariable=mqtt_default)

    def pass_f():
        window_config.destroy()

    set_btn = tk.Button(window_config,text="Set config",command=pass_f,bg="#A3BE8C")

    logo.grid(row=0,column=0,columnspan=3)
    spotted_label.grid(row=1,column=0,columnspan=3)

    serverAux_title.grid(row=2,column=0)
    serverAux_label.grid(row=2,column=1)

    serverMain_title.grid(row=3,column=0)
    serverMain_label.grid(row=3,column=1)

    mqtt_title.grid(row=4,column=0)
    mqtt_label.grid(row=4,column=1)

    set_btn.grid(row=5,column=0,columnspan=3)
    

def init_screen(v=0,env=0):
    
    modules_log = list(map(lambda x : "Initializing {} ...".format(x),["serverAux","serverMain","aggregators","plugins","schedulers"]))
    mqtt_log    = ["Checking your broker connection "]
    
    all_log = mqtt_log+modules_log
    
    counter = 0 
    
    if os.path.isfile("./gui/config.json") or v == 1:
        
        window = tk.Tk()
        window.title("EXO")
        window.geometry("600x400")

        init_frame = tk.Frame(window)
        photo  = PhotoImage(file = "./icons/exo_logo.png")
        logo   = tk.Label(init_frame,image=photo)
        logo.pack(pady=20)
    
        img           = Image.open("./icons/file_icon.png")   
        resized_image = img.resize((20,20), Image.ANTIALIAS)
        file_image    = ImageTk.PhotoImage(resized_image)

        img           = Image.open("./icons/terminal.png")   
        resized_image = img.resize((40,40), Image.ANTIALIAS)
        terminal_image    = ImageTk.PhotoImage(resized_image)

        img           = Image.open("./icons/warning.png")   
        resized_image = img.resize((40,40), Image.ANTIALIAS)
        notifications_image    = ImageTk.PhotoImage(resized_image)

        img           = Image.open("./icons/update.png")   
        resized_image = img.resize((40,40), Image.ANTIALIAS)
        reports_image = ImageTk.PhotoImage(resized_image)

        GLOBAL_CATALOG["file"]          = file_image
        GLOBAL_CATALOG["terminal"]      = terminal_image
        GLOBAL_CATALOG["notifications"] = notifications_image
        GLOBAL_CATALOG["reports"]       = reports_image
        GLOBAL_CATALOG["logo"]          = photo

        title  = tk.Label(init_frame,text="Starting :: EXO modules")
        status = tk.Label(init_frame,text="...")

        progress = ttk.Progressbar(init_frame,length=100,orient='horizontal',mode = 'determinate')
        
        def make_progress(counter):

            global Mvar
            Mvar = [0]
            
            def f():
                threading.Thread(target=lambda : startup.starts(Mvar)).start()
            
            counter = 0 
            index_counter = 0 
        
            const = progress["length"]/len(all_log)
            f()
            while Mvar[0] == 0 :
               counter+=const 
               if index_counter < len(all_log):
                    index_counter += 1
               else:
                    index_counter = 0
               try:
                   if counter >= progress["length"]:
                        status["text"] = "{}".format(all_log[index_counter]) 
                        progress["value"] = 0 
                        counter = 0
                        index_counter = 0 
                   else:
                        status["text"] = "{}".format(all_log[index_counter])
                        progress["value"]+=counter
               except:
                    index_counter = 0
                    status["text"] = "{}".format(all_log[index_counter])
                    progress["value"] = 0 
                    counter = 0
                    
               time.sleep(2)
                                    
            init_frame.destroy()
            main_screen(window)
        
        threading.Thread(target=lambda : make_progress(counter)).start() 

        logo.pack(pady=20)
        title.pack()
        status.pack()
        progress.pack()

        init_frame.pack()

        window.mainloop()
    else:
        window_config = tk.Tk()
        window_config.title("Initial config")
        window_config.geometry("600x400")
        
        boot_window = tk.Frame(window_config)        
        photo  = PhotoImage(file = "./icons/exo_logo.png")
        logo_1 = tk.Label(window_config,image=photo)
        
        variables = [
            "aggregators",
            "plugins",
            "exo-server",
            "exo-cli"
        ]

        welcome_label = tk.Label(window_config,text=" W e l c o m e ! ",font=("Arial", 28))
        boot_logging = tk.Label(boot_window)
        progress = ttk.Progressbar(boot_window,length=100,orient='horizontal',mode = 'determinate')
        
        def log_progress():
            const = progress["length"]/len(variables)
            gnr = ConfigGeneral()
            for i in variables :
                log_pre = "Checking for :: {}".format(i)
                if gnr.check_env_var(i) == 1:
                    log = "Installing :: {}".format(i)
                    boot_logging["text"] = log                                
                    progress["value"] += const
                else:
                    log = "Just found {} !".format(i)
                    boot_logging["text"] = log
                    progress["value"] += const
                    
                    
                time.sleep(2)

            boot_window.destroy()
            choose_window.pack()
            
            spotted_label.grid(row=1,column=0,columnspan=3)

            serverAux_title.grid(row=2,column=0)
            serverAux_label.grid(row=2,column=1)

            serverMain_title.grid(row=3,column=0)
            serverMain_label.grid(row=3,column=1)

            mqtt_title.grid(row=4,column=0)
            mqtt_label.grid(row=4,column=1)

            set_btn.grid(row=5,column=0,columnspan=5)
        
        threading.Thread(target=log_progress).start()

        
        boot_logging.pack(anchor=CENTER)
        progress.pack(anchor=CENTER)

        welcome_label.pack(anchor=CENTER)
        logo_1.pack()
        boot_window.pack()
        
        init_frame = tk.Frame(window_config)
        choose_window = tk.Frame(window_config)
        
        spotted_label = tk.Label(choose_window,text="First initialization, configure the ports :: ")

        serverAux_default = tk.StringVar()
        serverAux_default.set("3030")        
        serverAux_title  = tk.Label(choose_window,text="Server aux port :: ")
        serverAux_label  = tk.Entry(choose_window,textvariable=serverAux_default)
        
        serverMain_default = tk.StringVar()
        serverMain_default.set("3000")
        serverMain_title  = tk.Label(choose_window,text="Server main port :: ")
        serverMain_label = tk.Entry(choose_window,textvariable=serverMain_default)

        mqtt_default = tk.StringVar()
        mqtt_default.set("localhost:1883")
        mqtt_title  = tk.Label(choose_window,text="Broker port :: ")
        mqtt_label = tk.Entry(choose_window,textvariable=mqtt_default) 

        def pass_f():

            s0 = serverMain_label.get()
            s1 = mqtt_label.get()
            s2 = serverAux_label.get()

            ConfigGeneral().create_config(s1,s0,s2)
            window_config.destroy()
            init_screen(1)

        set_btn = tk.Button(choose_window,text="Set config",command=pass_f,bg="#A3BE8C") 
        
                
        window_config.mainloop()


def main():
    
    init_screen()      
    
if __name__ == "__main__":
    main()
