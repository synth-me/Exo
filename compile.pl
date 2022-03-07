use warnings ; 
use strict ; 

sub download_mqtt_package {
  # here we download the mqtt basic package and vendorize it in everry folder of the
  # project 
};

sub insert_variables {
  # here we insert the dependencies and the path of the variables 
};

sub install_dependencies {

  # here we download the dependencies 

  my $python_dependencies = "";
  my $stack_dependencies  = "";
  my $perl_dependencies   = "";
  my $node_dependencies   = ""; 
};

sub check_dependencies {
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
