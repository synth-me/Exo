#cd ..
#cd plugins

$pathAbs = Get-Location

$gitLink = $args[0]
$lang    = $args[1] 

$test = Test-Path -Path "temp"

if($test){ 
	Remove-Item -Path "temp" -Force	-Recurse 
};

function pipePath($mode){ 
	perl "compilation.pl" $mode ;	
};


git clone $gitLink temp

$p = pipePath $lang;

if($p -eq "1"){ 
	Get-ChildItem -Path ./temp/*.js -Name | ForEach-Object { 
		$n = $_ ; 
		$testF = Test-Path -Path ./rules/$n
		if($testF){
			del ./rules/$n 		
		};  
		Move-Item -Path ./temp/$n -Destination ./rules 
	};

	Get-ChildItem -Path ./temp/*.json -Name | ForEach-Object { 
		$n = $_ ;
		$testF = Test-Path -Path ./rules/$n
		if($testF){
			del ./rules/$n		
		};  
		Move-Item -Path ./temp/$n -Destination ./rules/$n
	};

	# cd .. 
	# cd .. 
	# cd exo-cli

}else{
	echo "Failed to compile using $arg"
	cd ..
};

