{-# LANGUAGE OverloadedStrings #-}

import Control.Concurrent
import Data.List.Split
import Data.Aeson as A hiding (Options)
import qualified Data.List as D 
import qualified Data.ByteString.Lazy.Char8 as BLU hiding (putStrLn)
import Flow 
import Text.Regex.TDFA
import Text.Regex.TDFA.Text 
import Network.URI
import Network.HTTP.Conduit
import Network.MQTT.Arbitrary
import Network.MQTT.Client 
import Network.MQTT.Topic (Topic,Filter,toFilter,mkTopic,mkFilter,unTopic)
import Network.MQTT.Types (SubErr,QoS)
import System.Environment 
import System.Process
import System.Directory
import System.IO
import Report 

printListAgg xs = mapM_ (\(a,b) -> putStr a >> putStr ("  " ++ show b) >> putStrLn "") xs
printListPlg xs = mapM_ (\(a,b,c,d) -> putStr a >> putStr ("  " ++ show b) >> putStrLn "") xs
printListSc  xs = mapM_ (\(a,b,c,d,e) -> putStr a >> putStr ("  " ++ show b) >> putStrLn "") xs

data Options = Options {
	command :: String,
	function :: APIAcess
}   

type APIAcess = [String] -> IO(String) 

help_log :: APIAcess 
help_log x = do
	let help = "  epm --del [mode] [name]                       <- delete items \n \
				\ epm --w [mode] [name]                         <- make new items \n \
				\ epm --m [mode]                                <- monitor current items \n \
				\ epm --notifications                           <- watch live notifications \n \
				\ epm --notifications:regex [regex]             <- watch current notifications with regex filter \n \
				\ epm --reports                                 <- watch current reports \n \
				\ epm --reports:regex [filter] [options]        <- watch current reports with regex filter \n \
				\ epm --install [link] [options]                <- install new packages from git repo \n \ 
				\ epm --clear [mode]                            <- delete all of a item category \n \  
				\ epm --help                                    <- display this help \n \ 
				\  " 
	return help 
	

accessReportFiltered :: APIAcess
accessReportFiltered input = do	
	putStrLn "Current filtered reports :: "
	addressLink <- addressNetworkConf
	let (Just uri) = parseURI $ mqtt_address addressLink
	mc <- connectURI mqttConfig{_msgCB=SimpleCallback msgReceived } uri	
	sbrc <- subscribe mc [("+/output",subOptions)]  []
	waitForClient mc
	return ".."
	where 	
		msgReceived _ t m p = do
			m 
			|> \x -> case A.decode x :: Maybe [Report] of
						 Just decoded  ->  do  
						 	input |> head |> \a -> do
						 						print ( a == "warnKind")
						 	let selected = case head input of 	
									 		"warnkind" 	   -> Left warnKind
									 		"reviewStatus" -> Left reviewStatus
									 		"logBody"	   -> Right logBody
											_              -> Right logBody 

							case selected of
								Left selected_left ->  
										decoded 
											|> filter (\a -> (selected_left a) =~ (last input) :: Bool)
											|> print 
								Right selected_right -> 
										decoded
											|> filter (\l0 ->  all(\a -> a =~ (last input) :: Bool ) (selected_right l0) )
											|> print
							
						 	
						 Nothing -> do 
						 	putStrLn "The exit report isnt well formatted , considering only the regex ..."
							let k = x 
									|> BLU.unpack 
									|> \a -> if (a =~ (last input) :: Bool) then a else "" 

							putStrLn k
								


acessNotificationFiltered :: APIAcess
acessNotificationFiltered input = do
	putStrLn "Current filtered notifications :: "
	addressLink <- addressNetworkConf
	let (Just uri) = parseURI $ mqtt_address addressLink
	mc <- connectURI mqttConfig{_msgCB=SimpleCallback msgReceived } uri	
	sbrc <- subscribe mc [("notifications",subOptions)]  []
	waitForClient mc
	return "..."
	where 
		msgReceived _ t m p = do
			let n = m |> BLU.unpack |> \z -> if (z =~ (last input) :: Bool ) then z else ""
			putStrLn n

	

accessNotificationAPI :: APIAcess
accessNotificationAPI x = do
	putStrLn "Current notifications :: "
	addressLink <- addressNetworkConf
	let (Just uri) = parseURI $ mqtt_address addressLink
	mc <- connectURI mqttConfig{_msgCB=SimpleCallback msgReceived } uri	
	sbrc <- subscribe mc [("notification",subOptions)]  []
	waitForClient mc
	return ".."
	where 
		msgReceived _ t m p = do
			m 
			|> BLU.unpack 
			|> putStrLn 

accessReportsAPI :: APIAcess
accessReportsAPI x = do
	putStrLn "Current reports :: "
	addressLink <- addressNetworkConf 
	let (Just uri) = parseURI $ mqtt_address addressLink
	mc <- connectURI mqttConfig{_msgCB=SimpleCallback msgReceived } uri	
	sbrc <- subscribe mc [("+/output",subOptions)]  []
	waitForClient mc
	return ".."
	where 
		msgReceived _ t m p = do
			m 
			|> BLU.unpack 
			|> putStrLn 
		
makeUrl :: String -> [String] -> Maybe Int -> [String] -> String -> IO(String) 
makeUrl route prmt valid content addressNetwork
	| ((length prmt) >= (length content)) && valid == Nothing = do
		makeUrl route prmt (Just 1) content addressNetwork 
	| valid == Just 1 = do
		[x | x <- [0..length prmt]]
			|> zip3 content prmt 
			|> map (\(a,b,c) -> if c == 0 then addressNetwork++route++"?"++a++"="++b else "&"++a++"="++b )
			|> concat
			|> return 

addressNetworkConf :: IO(AdressConfig)
addressNetworkConf = do
	r <- readFile "./address.json"
	case (r |> BLU.pack |> A.decode) :: Maybe AdressConfig of 
		Just x -> do
			return x  
		Nothing -> do
			let addr = AdressConfig "http://localhost:3000/" "mqtt://localhost:1883"
			return addr
	
makeRequest :: String -> IO(String)
makeRequest url = do
	response <- simpleHttp url
	response 
		|> BLU.unpack 
		|> return 

accessWriteAPI :: APIAcess
accessWriteAPI x = do
	if (head x `elem` ["schedule","plugin","cluster"])
		then do
			x
			|> head 
			|> flip (++) "-create"
			|> \z -> case (head $ splitOn "-" z) of
						"plugin" 	-> (["name_module","agg_route","script_path"],z) 
						"scheduler" -> (["name_schedule","mode","time","message_notify","scheduler_check"],z)
						"cluster"	-> (["name_agg","routes"],z)
			|> \(a,b) -> do
				addressNetworkC <- addressNetworkConf 
				let addressNetwork = interface_address addressNetworkC							
				let m = makeUrl b (tail x) Nothing a addressNetwork
				return m 
			|> \a -> do
				 link_i <- a 
				 link <- link_i
				 m <- makeRequest link
				 return m
		else 
			return $ "Item "++(head x)++" not found"

accessMonitorAPI :: APIAcess
accessMonitorAPI x = do
	addressNetwork <- addressNetworkConf
	if (head x `elem` ["schedule","plugin","cluster","output","notification"]) 
		then do 
			let link = x |> head |> (++) (interface_address addressNetwork) |> flip (++) "-monitor" 
			r <- makeRequest link
			putStrLn $ r
			return ""
		else do 
			return $ "Item "++(head x)++" not found"

accessInstallAPI :: APIAcess
accessInstallAPI x = do
	x 
	|> \u -> do
		addressNetwork <- addressNetworkConf
		m <- makeUrl "install" u Nothing ["link","lang"] (interface_address addressNetwork)
		return m
	|> \x -> do
		link <- x 
		m <- makeRequest link
		return m 

accessDelAPI :: APIAcess
accessDelAPI x = do
	if (head x `elem` ["schedule","plugin","cluster"]) 
		then do 
			  x 
			  |> head 
			  |> flip (++) "-delete"
			  |> \u -> do
			  	 addressNetwork <- addressNetworkConf
			  	 m <- makeUrl u (tail x) Nothing ["info"] (interface_address addressNetwork)
			  	 return m
			  |> \a -> do
			  	 link <- a
			  	 m <- makeRequest link
			  	 return m 
		else do
			return $ "Item "++(head x)++" not found"

accessConfigAPI :: APIAcess
accessConfigAPI x = do 
	return $ "New ADDRESS :: "++(head x)
		
accessExportAPI :: APIAcess
accessExportAPI x = do
	print x 
	return "teste"

accessClearAPI :: APIAcess
accessClearAPI x = do
	if (head x `elem` ["scheduler","plugin","cluster","output","notification"])
		then do 
			x 
			|> head 
			|> \a -> do
				addressNetwork <- addressNetworkConf
				m <- makeUrl "clear" [a] Nothing ["info"] (interface_address addressNetwork)
				return m 
			|> \a -> do 
				link <- a 
				m <- makeRequest link
				return m 
		else do
			return $ "Item "++(head x)++" not found"

 
currentOptions :: [Options]
currentOptions = [
		Options "--w" 					accessWriteAPI , 		   -- writing new items 
		Options "--m" 				    accessMonitorAPI ,	       -- monitoring items 
		Options "--del" 				accessDelAPI,		       -- deleting items
		Options "--epx" 				accessExportAPI,	       -- exporting as xlsx 
		Options "--clear" 				accessClearAPI,	 		   -- clear files 
		Options "--install" 			accessInstallAPI,          -- install packages  
		Options "--cfg" 				accessConfigAPI,	       -- change configurations ( address of mqtt )
		Options "--notifications" 		accessNotificationAPI,     -- watch the current notifications live 
		Options "--notifications:regex" acessNotificationFiltered, -- watch the current notifications live 
		Options "--reports:regex" 		accessReportFiltered,      -- watch the current filtered reports live
		Options "--reports" 			accessReportsAPI , 		   -- watch the curent reports 
		Options "--help" 				help_log		           -- see all options 
	]

main = do
	options <- getArgs 
	let o = options |> head |> flip elem (map command <| currentOptions)
	if o == True 
		then do
			let c = currentOptions
					|> filter (\y -> (command y) == (head options)) 
					|> head 
					|> function  
					|> \f -> (options |> tail |> f)
			fnl <- c

			case fnl of 
				"1" 		-> do putStrLn "Success"  
				"0"			-> do putStrLn "Failed" 
				"Success"	-> do putStrLn "Success" 
				"Failed"	-> do putStrLn "Failed" 
				_ 			-> do fnl |> putStrLn 
		else 
			putStrLn $ "Your command "++(head options)++" was not found"		


-- eof 
