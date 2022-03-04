
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE BlockArguments #-}
{-# LANGUAGE ScopedTypeVariables #-}

import GHC.Generics
import Control.Exception 
import Control.Concurrent 
import Control.Monad (forever)
import Data.Algorithm.Diff 
import qualified Data.ByteString.Lazy as BLU hiding (intercalate,takeWhile,find,putStrLn,filter,map,head,hGetContents)
import qualified Data.ByteString.Lazy.Char8 as C
import qualified Data.ByteString.UTF8 as U  
import Data.Aeson hiding (Success)
import Data.Text as T hiding(filter,map,head,find,takeWhile,intercalate,splitOn)
import Data.Foldable (find)  
import Data.List
import Data.List.Split (splitOn)
import Flow
import Network.URI
import Network.MQTT.Arbitrary
import Network.MQTT.Client 
import Network.MQTT.Topic (Topic,Filter,toFilter,mkTopic,mkFilter,unTopic)
import Network.MQTT.Types (SubErr,QoS)
import Network.URI
import Network.HTTP.Conduit
import Network.HTTP.Types.URI
import Report 
import System.Directory
import System.Process
import System.Exit
import System.Console.Pretty
import System.IO  
import System.Environment   

test_file :: IO(String)
test_file = do
	c_path <- getCurrentDirectory
	let test_path_0 = intercalate "\\" $ takeWhile (/="exo") $ splitOn "\\" c_path
	let test_path   = test_path_0++"\\exo\\plugins\\rules\\"
	return test_path

log_file :: IO(String)
log_file = do
	c_path <- getCurrentDirectory
	let test_path_0 = intercalate "\\" $ takeWhile (/="exo") $ splitOn "\\" c_path
	let test_path   = test_path_0++"\\exo\\aggregator\\logs\\"
	return test_path

{-
	Here we connect one point to the "-input" and the other 
	to the "-output" and for each connection a terminal socket
	is spawned with the mruby interpreter + the main process file + user file
	and the main file spurs the result to the stdout that goes in the stdout 

	For each of this actors there's supervisor of the config file which will
	disconnect the current connections if it perceives that the given module
	isnt declared in the config file a5;nymore.

-}

makeRequest :: String -> IO(String)
makeRequest url = do
	response <- simpleHttp url
	response 
		|> C.unpack 
	 	|> return 

getAddress :: IO(String)
getAddress = do
	args <- getArgs
	args 
		|> head 
		|> \x -> "mqtt://"++x
		|> return 

sub_get_single :: ConfigType -> IO ()
sub_get_single config_t = do
	address_link <- getAddress
	let name = name_module config_t
	let (Just uri) = parseURI address_link
	mc <- connectURI mqttConfig{_msgCB=SimpleCallback msgReceived } uri
	let fMList = map create_filter $ agg_route config_t 
	let fMList_f = map (\a -> (a,subOptions) ) fMList
	sbrc <- subscribe mc fMList_f  [] 
	f <- forkIO $ monitor_state config_t mc	
	waitForClient mc
	where 
		msgReceived _ t m p = do
			address_link <- getAddress
			let filtered = config_t
								|> agg_route
								|> map T.pack  
								|> map (\i -> case mkTopic i of 
												Nothing -> ""
												Just x -> x)
								|> filter (/=t) 
								|> map unTopic
								|> map T.unpack
			log <- log_file
			sideContent <- mapM (\f -> do
										r <- BLU.readFile $ log++"log_"++f++".json"
										case decode_as_inpt r of
											Nothing -> return GenericAggregator {name_log="",current_data=[]}
											Just r -> return r ) filtered	
			let z = script_path config_t
			    y = create_topic config_t 1 
			    (Just uri) = parseURI address_link
			mc1 <- connectURI mqttConfig uri 
			case (decode_as_inpt m) of
				Nothing -> do
					let error_log = "Error of input decoding at :: [ "++z++" ]"
					let report = encode $ Report { warnKind = "Plugin Error",reviewStatus = "Plugin Failure" ,logBody = [error_log] }
					publish mc1 "notification" report False 
				Just py -> do
					r <- request_script z $ encode $ [py]++sideContent
					publish mc1 y (BLU.fromStrict $ U.fromString $ r ) False

{-
	Here we decode the stdin as input data
	and decode stdout data as report  
-}

decode_as_inpt :: BLU.ByteString -> Maybe GenericAggregator
decode_as_inpt b = decode b :: Maybe GenericAggregator

decode_as_report :: BLU.ByteString -> Maybe Report
decode_as_report b = decode b :: Maybe Report

test_report_stdout :: BLU.ByteString -> IO Report
test_report_stdout b = do
	let d = decode_as_report b
	case d of 
		Nothing -> do 
			let diag = logTemplate "-" "Failure" ["Internal Error"]
			return diag 
		Just r  -> do 
			return r 
			

{-	############################################## -}


{-
	Here we transform strings in topics or filters 
	by adding "-input" or "-output" depending upon the situation 
-}

create_filter :: String -> Filter
create_filter x = 
	case(mkFilter t) of
		Nothing -> ""
		Just a  -> a
	where 
		t = T.pack $ "agg/"++(x)++"-output"  
		
create_topic :: ConfigType -> Int -> Topic
create_topic x n =
	case(mkTopic t) of
		Nothing -> ""
		Just a  -> a
	where 
		t = if n == 1 
				then T.pack $ (name_module x)++"/output" 
				else T.pack $ (name_module x)++"-input"

{-	############################################## -}


request_script :: String -> C.ByteString -> IO(String)
request_script file inpt = do
	let url_b   = "http://localhost:3030/run"
	let n_file  = U.fromString file 
	let n_inpt  = U.fromString $ C.unpack $ inpt
	let getData = [("name",Just n_file),("input",Just n_inpt)] :: [(U.ByteString,Maybe U.ByteString)]
	let query   = renderQuery True getData |> U.toString
	makeRequest (url_b++query) >>= return 
	
{-	############################################## -}


{-
	Here we read the config file and transform it into
	the configtype to check which modules to load 
-}

read_config :: IO(Maybe [ConfigType])
read_config = do
	handle <- openFile "./rules/config.json" ReadMode  
	contents <- hGetContents handle  
	let d = decode (BLU.fromStrict $ U.fromString $ contents) :: Maybe [ConfigType]
	return d 

{-	############################################## -}

{-
	Here we keep checking the config file to find negative 
	diffrences, if the current client isnt in the file anymore
	it will disconnect the actual client from the broker 
	and then kill itself thread 
-}


monitor_state :: ConfigType -> MQTTClient -> IO()
monitor_state c q = do 
	threadDelay 5000000
	let name = name_module c
	actual_config <- read_config 
	case actual_config of 
		Nothing -> do 
			(monitor_state c q) 
		Just a  -> do 
			let t = a |> map (name_module) |> Prelude.elem name 
			if t 
				then do	
					monitor_state c q 
				else do  
					normalDisconnect q
					putStrLn $ "Disconnected :: ["++name++"]"
					ct <- myThreadId
					killThread ct 

{-	############################################## -}

{-
	Based on the current config type we can start new connections 
-}

spawn_connection :: ConfigType -> IO()
spawn_connection c = do
	f <- forkIO $ sub_get_single c
	threadDelay (2000000)
	putStrLn $ color Green $ "New Connection :: [ "++(name_module c)++" ]"

{-	############################################## -}

{-
	Here we keep checking the config file to check positive
	changes, if any new moduele is added this will spawn the new 
	connections needed 
-}

keep_checking :: [ConfigType] -> IO()
keep_checking config_old = do
	config <- read_config 
	case config of	
		Nothing -> do
			putStrLn $ color Yellow "File in use , not spawing any new connections by now ..."
			keep_checking config_old
		Just config_new -> do
			let d  = getDiff config_old config_new 
			mapM_ (\y -> do
						case y of
							Second a -> spawn_connection a
							_ 		 -> return()
						) $ d
			keep_checking config_new  

{-	############################################## -}

{-
	Here we first spawn the needed connections , the ones
	declared in the first version of the config file
-}

start_process :: [ConfigType] -> IO()
start_process a = do
	putStrLn $ color Yellow $ "Initializing first connections ..."
	threadDelay 3000000
	mapM_ (\t -> do spawn_connection t ) $ a
	
{-	############################################## -}

mainThread = do
	threadDelay (2*10^6)
	mainThread

main = do 
	hSetBuffering stdout NoBuffering
	putStrLn "Started process"
	r <- read_config 
	case r of 
		Nothing -> do 
			putStrLn $ color Red $ "Your config.json file isnt formatted as it should be, review it"
			threadDelay 3000000
			main 
		Just a -> do  
			forkIO $ start_process a 
			threadDelay 3000000
			forkIO $ keep_checking a 
			mainThread
						
-- eof 
