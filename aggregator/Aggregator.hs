{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE BlockArguments #-}
{-# LANGUAGE ScopedTypeVariables #-}

import GHC.Generics
import Control.Exception 
import Control.Concurrent 
import Control.Monad (forever,unless)
import Data.Algorithm.Diff 
import Data.ByteString.Lazy as BLU hiding (find,putStrLn,filter,map,head,hGetContents)
import Data.ByteString.UTF8 (fromString) 
import Data.Aeson hiding (Success)
import Data.Aeson.Text (encodeToLazyText)
import Data.Text as T hiding(filter,map,head,find)
import Data.Text.Lazy.IO as I hiding (putStrLn,hGetContents)
import Data.Foldable (find)  
import Data.Time.Clock
import Data.Time.Calendar
import Flow
import Network.URI
import Network.MQTT.Arbitrary
import Network.MQTT.Client 
import Network.MQTT.Topic (Topic,Filter,toFilter,mkTopic,mkFilter,unTopic)
import Network.MQTT.Types (SubErr,QoS) 
import System.Process
import System.Exit
import System.Console.Pretty
import System.IO
import System.Directory
import System.Environment   

data AggConfig = AggConfig {
	name_agg :: String , 
	routes :: String
} deriving(Show,Generic,Eq)

data GenericAggregator = GenericAggregator {
	name_log :: String , 
	current_data :: [(String,Float)]
} deriving(Show,Generic,Eq)

data Report = Report {
	warnKind::String,
	reviewStatus::String,
	logBody::[String]	
} deriving (Show,Generic)

data CMode = CMode {
	mode :: String , 
	moment_data :: [(String,Float)]
} deriving (Show,Generic)

instance FromJSON CMode
instance ToJSON CMode

instance FromJSON AggConfig
instance ToJSON AggConfig

instance FromJSON GenericAggregator
instance ToJSON GenericAggregator

instance FromJSON Report
instance ToJSON Report

read_config :: IO(Maybe [AggConfig])
read_config = do
	handle <- openFile "./agg.json" ReadMode
	contents <- hGetContents handle
	let d = decode (BLU.fromStrict $ fromString $ contents) :: Maybe [AggConfig]
	return d

create_filter :: String -> Filter
create_filter x = 
	case(mkFilter t) of
		Nothing -> ""
		Just a  -> a
	where 
		t = T.pack $ x

create_topic :: String -> Topic
create_topic x =
	case(mkTopic t) of
		Nothing -> ""
		Just a  -> a
	where 
		t = T.pack $ x

create_report :: String -> Report  
create_report s = Report {
		warnKind = "Connection", 
		reviewStatus = "Success", 
		logBody = [s]
	}

getAddress :: IO(String)
getAddress = do
	args <- getArgs
	args 
		|> head 
		|> \x -> "mqtt://"++x
		|> return 
	
single_spawn :: AggConfig -> IO ()
single_spawn a = do
	address_link <- getAddress
	let name = name_agg a 
	putStrLn $ color Green $ "Aggregator spawn :: [ "++name++" ]"
	let (Just uri) = parseURI address_link
	mc   <- connectURI mqttConfig{_msgCB=SimpleCallback msgReceived} uri
	sbrc <- subscribe mc [((create_filter $ "sensor/"++(routes a)++"/#" ), subOptions) ]  []
	f 	 <- forkIO $ monitor_state a mc
	waitForClient mc
	where 
		msgReceived _ t m p = do
			address_link <- getAddress
			let file = "./logs/log_"++(name_agg a)++".json"
			let (Just uri) = parseURI address_link
			mc1  <- connectURI mqttConfig uri
			ch <- doesFileExist file

			unless ch $ do
				I.writeFile file $ encodeToLazyText $ GenericAggregator { name_log = name_agg a, current_data = [] }
			
			handle   <- openFile file ReadMode
			contents <- hGetContents handle 
			
			let d = decode (BLU.fromStrict $ fromString $ contents) :: Maybe GenericAggregator										
			case d of 
				Nothing -> do 
					putStrLn $ color Red $ "Bad formatting"
				Just k -> do 
					case (decode m :: Maybe Float) of
						Nothing -> do
							putStrLn $ color Red $ "Bad entrance info "							
						Just km -> do 
							let current_connections = map (\(x,y) -> x) $ current_data k 
							let current_topic 		= (T.unpack $ unTopic t)
							if not(Prelude.elem (T.unpack $ unTopic t) current_connections ) 
								then do
									let cp  = (current_data k)++[(current_topic,0.0)]
									let rst = map (\(f,g) -> if (f) == (current_topic) then (f,km) else (f,g) ) $ cp
									I.writeFile file $ encodeToLazyText $ GenericAggregator { name_log = name_log k , current_data = rst }
									publish mc1 (create_topic ("agg/"++(name_agg a)++"-output")) (BLU.fromStrict $ fromString $ show $ rst ) False
									(y,m,d) <- current_date 		
									let log = encode $ create_report $ "New sensor [ "++current_topic++" ]"++" [ "++(show d)++"/"++"/"++(show m)++"/"++(show y)++" ]"
									putStrLn $ color Blue $ "New sensor [ "++current_topic++" ]"++" [ "++(show d)++"/"++"/"++(show m)++"/"++(show y)++" ]"
									publish mc1 (create_topic "notification") (BLU.fromStrict $ fromString $ show $ log ) False
								else do 
									let rst = map (\(f,g) -> if (f) == (current_topic) then (f,km) else (f,g) ) $ current_data k 
									let rst_g = GenericAggregator { name_log = name_log k , current_data = rst }
									I.writeFile file $ encodeToLazyText $ rst_g
									publish mc1 (create_topic ("agg/"++(name_agg a)++"-output")) (encode rst_g ) False
									let make_ = CMode "train" (current_data rst_g) 
									publish mc1 (create_topic ("notification/resilience/"++(name_agg a)) )	 (encode make_) False 

current_date :: IO (Integer, Int, Int) 
current_date = getCurrentTime >>= return . toGregorian . utctDay

spawn_new_agg :: [AggConfig] -> IO()
spawn_new_agg agg = do
	putStrLn $ color Yellow $ "Initializing aggregators ..."
	mapM_ (\a -> do
		(threadDelay 3000000)
		forkIO $ single_spawn a
		) $ agg

monitor_state :: AggConfig -> MQTTClient -> IO()
monitor_state c q = do
	(threadDelay 5000000)
	let name = name_agg c 
	actual_config <- read_config
	case actual_config of
		Nothing -> do	
			(monitor_state c q) 
		Just a -> do 
			let t = a |> map (name_agg) |> Prelude.elem name 
			if t 
				then do
					monitor_state c q
				else do
					normalDisconnect q
					putStrLn $ color Red $ "Disconnected :: ["++name++"]"
					ct <- myThreadId
					killThread ct


keep_checking :: [AggConfig] -> IO()
keep_checking aggr = do
	config <- read_config
	case config of
		Nothing -> do
			putStrLn $ color Yellow "File in use or decode error, waiting..."
			keep_checking aggr
		Just aggr_new -> do 
			let d = getDiff aggr aggr_new
			mapM_ (\y -> do
						case y of 
							Second a -> single_spawn a 
							_ 		 -> return ()
					) $ d 
			keep_checking aggr_new 

mainThread = do
	threadDelay (2*10^6)
	mainThread
			
main = do 
	r <- read_config 	
	case r of  
		Nothing -> do 
			putStrLn $ color Red $ "Your agg.json file isnt formatted as it should be, review it"
			main
		Just a -> do
			forkIO $ spawn_new_agg a 
			forkIO $ keep_checking a
			mainThread
						
			

-- eof 
