{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE BlockArguments #-}
{-# LANGUAGE ScopedTypeVariables #-}


module Interface where 

import System.IO
import System.Environment
import Control.Monad 
import GHC.Generics
import System.IO
import Report 
import Network.URI
import Network.HTTP.Conduit
import Text.Show.Unicode 
import Text.Emoji 
import System.Console.Pretty
import System.Directory
import System.Process
import Data.ByteString.Lazy as BLU hiding (last,intercalate,elem,any,find,putStrLn,filter,map,head,hGetContents,takeWhile)
import Data.ByteString.UTF8 (fromString)  
import Data.Aeson (decode,encode)
import Data.Text.Lazy.IO as I hiding (putStrLn,hGetContents,getLine)
import Data.Aeson.Text (encodeToLazyText)
import Data.List.Split
import Data.List hiding (intersect) 
import Flow

data NamedPipe = NamedPipe {
	file :: String, 
	pipe_command :: String 
} deriving (Show)

decode_as_recipe :: ByteString -> Maybe Recipe
decode_as_recipe b = decode b :: Maybe Recipe

make_my_package :: IO()
make_my_package = do putStrLn $ color Yellow $ "Choose"

write_success :: Recipe -> IO()
write_success rcp = do 
	let p = rcp 
	handle <- openFile "./packages.json" ReadMode
	contents <- hGetContents handle 
	case (decode (BLU.fromStrict $ fromString $ contents) :: Maybe [Recipe]) of
		Nothing -> do
			putStrLn $ color Red $ "The package declation file crashed"
		Just f -> do
			putStrLn $ color Green "Registering the packaged name"
			let l = f++[p] 
			let e = encodeToLazyText l  
			I.writeFile "./packages.json" e
			putStrLn $ color Green $ "Successfully registered your new package"

intersect :: [String] -> [String] -> [String]
intersect [] _ = []
intersect _ [] = []
intersect xs ys = filter (\x -> x `elem` xs) ys

agg_path_io :: IO(String)
agg_path_io = do 
	c_path <- getCurrentDirectory
	let agg_path_0 = intercalate "\\" $ takeWhile (/="exo") $ splitOn "\\" c_path
	let agg_path   = agg_path_0++"\\exo\\aggregator\\agg.json"
	return agg_path

config_path_io :: IO(String)
config_path_io = do 
	c_path <- getCurrentDirectory
	let config_path_0 = intercalate "\\" $ takeWhile (/="exo") $ splitOn "\\" c_path
	let config_path   = config_path_0++"\\exo\\plugins\\rules\\config.json"
	return config_path

rules_path_io :: IO(String)
rules_path_io = do 
	c_path <- getCurrentDirectory 
	let rule_path_0 = intercalate "\\" $ takeWhile (/="exo") $ splitOn "\\" c_path
	let rule_path = rule_path_0++"\\exo\\plugins\\rules\\"
	return rule_path

scheduler_path_io :: IO(String)
scheduler_path_io = do 
	c_path <- getCurrentDirectory 
	let sched_path_0 = intercalate "\\" $ takeWhile (/="exo") $ splitOn "\\" c_path
	let sched_path = sched_path_0++"\\exo\\scheduler\\scheduler.json"
	return sched_path

output_path_io :: IO(String)
output_path_io = do
	c_path <- getCurrentDirectory 
	let rule_path_0 = intercalate "\\" $ takeWhile (/="exo") $ splitOn "\\" c_path
	let rule_path = rule_path_0++"\\exo\\plugins\\logs\\output_log.json"
	return rule_path


notification_path_io :: IO(String)
notification_path_io = do
	c_path <- getCurrentDirectory
	let nl_path_0 = intercalate "\\" $ takeWhile (/="exo") $ splitOn "\\" c_path
	let nl_path   = nl_path_0++"\\exo\\aggregator\\logs\\notification_log.json"
	return nl_path
											
install_aggr :: Recipe -> IO()
install_aggr x = do
	agg_path <- agg_path_io
	handle   <- openFile agg_path ReadMode
	contents <- hGetContents handle
	case ( decode (BLU.fromStrict $ fromString $ contents) :: Maybe [AggConfig] ) of
		Nothing -> do
			putStrLn $ color Red $ "Bad agg formating" 
		Just k -> do
			putStrLn $ color Yellow $ "Installing Aggregators..."
			let i = map name_agg $ package_aggr x 
			let j = map name_agg k 
			if (intersect i j /= [])
				then do  
					putStrLn $ color Blue $ "Aggregator already found..."
				else do
					let p = k++(package_aggr x) 
					let e = encodeToLazyText $ p  
					I.writeFile agg_path e
					putStrLn $ color Green  $ "Successfully installed [ aggregator ] "
		

install_plugin_manifest :: Recipe -> IO()
install_plugin_manifest x = do
	putStrLn $ color Yellow $ "Started Plugin installation..."
	let module_name = map (\y -> (name_module y, script_path y)) $ package_plugin_config x 
	path     <- config_path_io
	handle   <- openFile path ReadMode
	contents <- hGetContents handle
	case (decode (BLU.fromStrict $ fromString $ contents) :: Maybe [ConfigType]) of 					
		Nothing -> do 
			putStrLn $ color Red $ "Bad config formating"
		Just k -> do 
			let i = map name_module $ package_plugin_config x  
			let j = map name_module k 
			if (intersect i j /= [])
				then do
					putStrLn $ color Blue $ "Plugin manifest already found..."
				else do 
					putStrLn $ color Yellow $ "Installing Plugin..."
					let p = encodeToLazyText $ k++(package_plugin_config x)
					I.writeFile path p 
					putStrLn $ color Green $ "Successfully installed [ plugin manifest ] "

general_install_procedure :: Recipe -> IO()
general_install_procedure recipe_struct = do
	putStrLn $ color Green $ "Installing :: [ "++(package_name recipe_struct)++" ]"
	(install_plugin_manifest recipe_struct)
	(install_aggr recipe_struct)
	(write_success recipe_struct)

pipeline_list :: [NamedPipe]
pipeline_list = 
	[
		NamedPipe "purescript" "psc",
		NamedPipe "coffeescript" "coffee",
		NamedPipe "typescript" "typ",
		NamedPipe "ruby" "opal -c",
		NamedPipe "livescript" "lsc -c"
	]

exe_recipe :: String -> String -> IO(String)
exe_recipe recipe_path language = do
	putStrLn $ color Yellow $ "Trying to solve recipe file..."
	q <- doesFileExist recipe_path
	let t = (parseURI recipe_path, q) 
	case (t) of
		(Nothing,False)  -> do 
			putStrLn $ "Could not solve URl , Local file or public package "
			return "Could not solve URl , Local file or public package "
		(Just url,_) -> do
			let clone_r = "Powershell.exe .\\clone.ps1 "++(show url)++" "++(language) 
			bx <- readCreateProcessWithExitCode ( shell clone_r ) ""
			r  <- rules_path_io
			bs <- BLU.readFile $ r++"index.json"
			case (decode_as_recipe bs :: Maybe Recipe) of
				Nothing -> do
					putStrLn $ "Bad formatted recipe file !"
					return "Bad formatted recipe file !"
				Just d  -> do 
					g <- general_install_procedure d
					putStrLn $ "Great ! Your package was successfully installed !"
					return "Great ! Your package was successfully installed !"
		(Nothing,True) -> do
			putStrLn $ "Great ! Your package was successfully installed or updated installed !"
			return "Great ! Your package was successfully installed or updated installed !"

clear :: String -> IO(Int)
clear x = do
	System.IO.writeFile x "[]"
	contents <- System.IO.readFile x
	if contents == "[]" then
		return 1
	else 
		return 0

clearTool :: String -> IO(Int)
clearTool x 
	| x == "scheduler" = do
		scheduler_path_io >>= clear  
	| x == "plugin" = do
		config_path_io >>= clear 
	| x == "notification" = do
		notification_path_io >>= clear 
	| x == "report" = do
		output_path_io >>= clear 
	| x == "cluster" = do
		agg_path_io >>= clear 
	| x == "all" = do
		mapM_ clearTool ["scheduler","plugin","notification","report","cluster"]
		return 1 
	| otherwise = do 
		return 0	
	
-- eof 
