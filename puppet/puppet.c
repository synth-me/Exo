#include <stdlib.h> 
#include <stdio.h>
#include <dirent.h>
#include <string.h>
#include <unistd.h> 

int getSize (char *s[]) {
	char ** t; 
	int size = 0;
	for (t = s; *t != 0; t++) { size++;}
	return size;
};

char* curdir(){
	static char cwd[256];
	chdir("./exo-cli");
	getcwd(cwd, sizeof(cwd));
	return cwd ;
};

char* monitor(int mode, char regex[]){
	static char str[250];
	int s = strcmp(regex,"default") ;
	switch(mode){
		case 1 : {
			if(!s){ sprintf(str,"epm --notifications");
			}else{  sprintf(str,"epm --notifications:regex %s",regex);};
			break;
		}
		case 2 : {
			if(!s){ sprintf(str,"epm --reports");	
			}else{  sprintf(str,"epm --reports:regex %s",regex);};
			break;
		}	
	};
	curdir();
	system(str);
	return str ; 
	
};

char* clear(int mode){

	static char str[250];
	switch(mode){
		case 1 : {			
			sprintf(str,"epm --clear cluster");
			break;
		}
		case 2 : {
			sprintf(str,"epm --clear plugins");
			break;
		}
		case 3 : {

			/* Not implemented */
			
			sprintf(str,"epm --clear schedulers");
			break;
		}
		case 4 : {
			sprintf(str,"epm --clear all");
			break;
		};
	};
	curdir();	
	system(str);
	return str ; 
};

char* install(char *link,char *language){
	static char str[250] ;
	sprintf(str,"epm --install %s %s",link,language);
	curdir();
	system(str);
	return str ; 
};

char* delPlugin(char *name){
	static char str[250];
	sprintf(str,"epm --del plugin %s",name);
	curdir();
	system(str);
	return str ; 
};

char* delAggr(char *name){
	static char str[250];
	sprintf(str,"epm --del cluster %s",name);
	curdir();
	system(str);
	return str ; 
};

char* delScheduler(char *name){

	/* Not implemented */

	static char str[250];
	sprintf(str,"epm --del scheduler %s",name);
	return str ; 
};


char* mkScheduler(char *name){

	/* Not implemented */

	static char str[250];
	return str ;
};


char* mkPlugin(char *name,char *routes, char *plugin_name){
	static char str[250];
	sprintf(str,"epm --w plugin %s %s %s",name,routes,plugin_name);
	curdir();
	system(str);
	return str ; 
};


char* mkAggr(char *name,char *route){
	static char str[250] ;
	sprintf(str,"epm --w cluster %s %s",name,route);
	curdir();
	system(str);
	return str ; 
};

char* inspect(int mode){
	static char str[250] ;
	switch(mode){
		case 1 : {
			sprintf(str,"epm --m cluster"); 
			break ; 
		}

		case 2 : {
			sprintf(str,"epm --m plugin");
			break ;
		}

		case 3 : {

			/* Not implemented */
		
			sprintf(str,"epm --m scheduler");
			break;
		}
			
	};
	curdir();
	system(str);
	return str ;
};	


// eof 
