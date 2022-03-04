

sub drawPipe{

	my ($enter,$compiler) = (@_);

	$pipeDraw = "
$enter		$compiler  
\n |  |____________| |
\n |_______   _______|
\n 	|  |
	\\  /
\n         js
\n
	";

	print $pipeDraw."\n" ; 
		
};


drawPipe "fsharp", "fable" ;



# eof 
