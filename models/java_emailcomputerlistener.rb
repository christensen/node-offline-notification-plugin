# To make tests work with our java classes
# the actual source file had to move into a directory called "src"
# in the root dir
# we need java libraries for environment variables and smtp settings 
$LOAD_PATH.push(File.dirname(__FILE__) + "/src")
require 'java_wrapper'
require 'emailcomputerlistener'
