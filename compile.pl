use strict ; 
use HTTP::Request;
use LWP::UserAgent ();  
use Data::Dumper; 
use Cwd qw(getcwd);

sub download_mqtt_package {
	my $arbritary_source = "Arbitrary.hs";
	my $client_source    = "Client.hs";
	my $topic_source     = "Topic.hs";
	my $types_sources    = "Types.hs";
	my @l = ($arbritary_source,$client_source,$topic_source,$types_sources);		
	my $ua = LWP::UserAgent->new(timeout => 10);
	$ua->env_proxy;
	my %hash_file_content = (); 
	print "Collecting shared library ... \n"; 
	foreach my $file (@l){
		my $template = "https://raw.githubusercontent.com/dustin/mqtt-hs/master/src/Network/MQTT/$file";
		my $response = $ua->get($template);
		$hash_file_content{$file} = $response->decoded_content;
	};
	my @folders = ("aggregator","plugins","exo-cli","exo-server");
	my $path = "";
	foreach my $folder (@folders){
		chdir("./$folder");
		$path = getcwd() ;
		print "Vendorizing on :: $path \n" ;
		mkdir("Network");
		chdir("./Network");
		mkdir("MQTT");
		chdir("./MQTT");	
		foreach my $key (keys %hash_file_content){
			open(FH,">",$key);
			print FH $hash_file_content{$key} ;
			print "Wrote $key \n";
			close(FH);
		};
		chdir("..");
		chdir("..");
		chdir("..");

		print getcwd() ; 
	};
	return 1 ; 
};


sub compile_haskell_source {
	print "Compiling Haskell : \n";
	my @folders = ("aggregator","plugins","exo-cli","exo-server"); 
	my $comand_aggr = "stack ghc -- aggregator.hs -threaded";
	my $command_plg = "stack ghc -- Plugins.hs -threaded";
	my $command_epm = "stack ghc -- epm.hs -threaded";
	my $command_ser = "stack ghc -- server.hs -threaded";
	my @command_list = ($comand_aggr,$command_plg,$command_epm,$command_ser);
	my $counter = 0 ;
	my $path = "";
	while($counter < 4){
		chdir("./$folders[$counter]");
		$path = getcwd() ; 
		print "Running on :: $path the command : $command_list[$counter] \n"; 
		system $command_list[$counter] ;
		chdir("..");
		$counter++ ; 	
	}; 
	return 1 ;
};

sub compile_C_source{
	chdir("./puppet") ;
	my $path = getcwd() ;
	my $command_C = "gcc -shared -o ./puppet.dll ./puppet.c"; 
	print "Compiling C dll or SO : \n";
	print "Running on :: $path the command : $command_C \n";
	chdir("..");
	return 1 ;
};


sub main{
	download_mqtt_package();
	compile_haskell_source();
	compile_C_source();
};


main();


# eof 
endencies {
  # here we check the after installation 
};

sub compile_source_codes {
  # here we compile the codes to single executables including python , perl and javascript scripts 
};

sub main {
  print "Started compilation ... \n" ; 
  install_dependencies();
  check_dependencies();
  compile_source_codes();
  insert_variables();
};

main();
