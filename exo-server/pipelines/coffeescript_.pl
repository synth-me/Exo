package coffeescript_ ; 

sub compile{
	my $current_dir = "./temp" ;
	opendir(DIR, $current_dir) or die $! ; 
	while(my $file = readdir(DIR)){
		if($file =~ m/.coffee$/){
			system "coffee", "-c", "./temp/$file" ; 
		}; 
	};
	
};


1;
