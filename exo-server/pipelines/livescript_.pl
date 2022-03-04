
package livescript_ ; 

use strict;
use warnings;

sub compile{
	my $current_dir = "./temp" ;

	opendir(DIR, $current_dir) or die $! ; 

	while(my $file = readdir(DIR)){
			if($file =~ m/.ls$/){
				system "lsc", "-c", "./temp/$file" ; 
		}; 
	};
	print STDOUT "1" ; 	
};


1;
# eof 
