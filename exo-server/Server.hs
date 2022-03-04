{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}

import Control.Concurrent
import Control.Monad
import Data.List (elemIndex)
import Data.List.Split 
import Data.Aeson (decode,encode)
import qualified Data.Text.Lazy.IO as I 
import Data.Aeson.Text (encodeToLazyText)
import qualified Data.ByteString.Lazy as BLU  
import Data.ByteString.UTF8 (fromString)  
import Data.ByteString.Builder as B
import Data.ByteString (ByteString,unpack)
import Flow
import Interface 
import Network.Wai
import Network.Wai.Handler.Warp
import Network.HTTP.Types
import Network.Wai.Application.Static
import Report 
import System.IO
import System.Process
import System.Environment   
import Network.Wai
import Network.Wai.Handler.Warp
import Network.HTTP.Types
import Network.Wai.Application.Static


-- Internals --

	-- Monitor tools --	

monitorPlugins :: IO(String)
monitorPlugins = do 
	file   	 <- config_path_io
	handle 	 <- openFile file ReadMode
	contents <- hGetContents handle
	return contents 

monitorCluster :: IO(String)
monitorCluster = do
	file   	 <- agg_path_io
	handle   <- openFile file ReadMode
	contents <- hGetContents handle
	return contents

monitorScheduler :: IO(String)
monitorScheduler = do
	file   	 <- scheduler_path_io
	handle   <- openFile file ReadMode
	contents <- hGetContents handle
	return contents

monitorOutput :: IO(String)
monitorOutput = do
	file   	 <- output_path_io
	handle   <- openFile file ReadMode
	contents <- hGetContents handle
	return contents

monitorNotification :: IO(String)
monitorNotification = do
	file   	 <- notification_path_io
	handle   <- openFile file ReadMode
	contents <- hGetContents handle
	return contents

	-------------

	-- write tools --

decode_to_config :: String -> Maybe [ConfigType]
decode_to_config content = decode (BLU.fromStrict $ fromString $ content ) :: Maybe [ConfigType]

writePlugins :: ConfigType -> IO(String)
writePlugins new_plugin = do
	content <- monitorPlugins
	path    <- config_path_io
	case (decode_to_config content) of
		Just x -> do
			let p = encodeToLazyText $ x++[new_plugin]
			I.writeFile path p 
			return "Success"						
		_			 -> do 
			return "Fail"

decode_to_cluster :: String -> Maybe [AggConfig]
decode_to_cluster content = decode (BLU.fromStrict $ fromString $ content ) :: Maybe [AggConfig]

writeCluster :: AggConfig -> IO(String) 
writeCluster new_cluster = do
	content <- monitorCluster
	path    <- agg_path_io
	case decode_to_cluster content of
		Just x -> do
			let p = encodeToLazyText $ x++[new_cluster]
			I.writeFile path p 
			return "Success"
		_			 -> do 
			return "Fail"

decode_to_scheduler :: String -> Maybe [ScheduleState]
decode_to_scheduler content = decode (BLU.fromStrict $ fromString $ content ) :: Maybe [ScheduleState]

writeScheduler :: ScheduleState -> IO(String)
writeScheduler new_scheduler = do
	content <- monitorScheduler
	path    <- scheduler_path_io
	case (decode_to_scheduler content) of
		Just x -> do
			let p = encodeToLazyText $ x++[new_scheduler]
			I.writeFile path p 
			return "Success"
		_			 -> do 
			return "Fail"

writePackage :: String -> String -> IO(String)
writePackage link lang = do
	e <- exe_recipe link lang
	putStrLn e 
	return e 
	
	-------------
	------Delete tools--------


deletePlugin :: String -> IO(String)
deletePlugin x = do 
	content 	<- monitorPlugins
	let db = decode_to_config content	
	case db of 
		Nothing -> do
			 return "Error of decoding db"
		Just a -> do
			c <- config_path_io
			a |> filter (\y -> (name_module y) /= x) |> encodeToLazyText |> I.writeFile c	
			return "Sucess"
	

deleteCluster :: String -> IO(String) 
deleteCluster x = do
	content <- monitorCluster 
	let db = decode_to_cluster content
	case db of 
		Nothing -> do
			return "Error of decoding db"
		Just a -> do
			c <- agg_path_io
			map name_agg a |> print 
			a |> filter (\y -> (name_agg y) /= x) |> encodeToLazyText |> I.writeFile c
			return "Sucess"
			
deleteScheduler :: String -> IO(String)
deleteScheduler x = do
	content <- monitorScheduler 
	let db = decode_to_scheduler content
	case db of 
		Nothing -> do
			return "Error of decoding db"
		Just a -> do
			c <- scheduler_path_io
			a |> filter (\y -> name_schedule y /= x) |> encodeToLazyText |> I.writeFile c
			return "Sucess"
	
	
	-------------
	

	------Internal tools-------

showStringUnslash :: String -> String
showStringUnslash x = 
	x 
	|> splitOn "\""
	|> init 
	|> last 

renderRequest :: (Maybe ByteString) -> String
renderRequest a = 
	case a of
		Nothing -> "0.0"	
		Just x 	-> show x 
		
	-------------
	
------------

renderString :: String -> Builder
renderString cs = charUtf8 '"' <> foldMap escape cs <> charUtf8 '"'
  where
      escape c = charUtf8 c


server :: IO ()
server = do
	args <- getArgs
	run (args |> head |> read :: Int) $ \req send ->
  		case pathInfo req of
			
			["output-monitor"] -> do
				response <- monitorOutput
				send $ responseBuilder status200 [("Content-Type", "text/plain")] $ renderString $ response

			["notification-monitor"] -> do
				response <- monitorNotification
				send $ responseBuilder status200 [("Content-Type", "text/plain")] $ renderString $ response

			["schedule-monitor"] -> do
				response <- monitorScheduler
				send $ responseBuilder status200 [("Content-Type", "text/plain")] $ renderString response
		
			["schedule-create"]  -> do 
				let query = queryString req :: [(ByteString, Maybe ByteString)]
				let scheduler_name = showStringUnslash $ renderRequest $ (join $ lookup "name_schedule" query)
				let scheduler_unity = showStringUnslash $ renderRequest $ (join $ lookup "mode" query)
				let scheduler_not = showStringUnslash $ renderRequest $ (join $ lookup "message_notify" query) 
				let scheduler_check = showStringUnslash $ renderRequest $ (join $ lookup "scheduler_check" query)
				let scheduler_time = showStringUnslash $ renderRequest $ (join $ lookup "time" query)
				let schedule_c = ScheduleState {
					name_schedule = scheduler_name , 
					mode = scheduler_unity, 
					time = read( scheduler_time) :: Float, 
					message_notify = scheduler_not ,
					path_log = scheduler_check
				}
				response <- writeScheduler $ schedule_c
				send $ responseBuilder status200 [("Content-Type", "text/plain")] $ renderString response

			["schedule-delete"]  -> do 
				let query = queryString req 
				let idParam = showStringUnslash $ renderRequest $ join $ lookup "info" query 
				content <- deleteScheduler idParam
				send $ responseBuilder status200 [("Content-Type", "text/plain")] $ renderString content 

			["plugin-monitor"] -> do
				response <- monitorPlugins
				send $ responseBuilder status200 [("Content-Type", "text/plain")] $ renderString response

			["plugin-create"] -> do 
				let query = queryString req :: [(ByteString, Maybe ByteString)]
				let plugin_name_d = showStringUnslash $ renderRequest $ (join $ lookup "name_module" query) 
				let plugin_agg_d = showStringUnslash $ renderRequest $ (join $ lookup "base_route" query) 
				let plugin_route_d = showStringUnslash $ renderRequest $ (join $ lookup "agg_route" query) 
				let plugin_script_d = showStringUnslash $ renderRequest $ (join $ lookup "script_path" query) 
				let plugin_c = ConfigType {
					name_module = plugin_name_d , 
					agg_route = [plugin_route_d] , 
					script_path = plugin_route_d 
				}
				putStrLn $ show $ plugin_c
				response <- writePlugins plugin_c
				send $ responseBuilder status200 [("Content-Type", "text/plain")] $ renderString response

			["plugin-delete"] -> do
				let query = queryString req 
				let idParam = showStringUnslash $ renderRequest $ join $ lookup "info" query 
				content <- deletePlugin idParam
				send $ responseBuilder status200 [("Content-Type", "text/plain")] $ renderString content 
		
			["cluster-monitor"] -> do
				response <- monitorCluster
				send $ responseBuilder status200 [("Content-Type", "text/plain")] $ renderString response

			["cluster-create"] -> do 
				let query = queryString req 
				let name_agg = showStringUnslash $ renderRequest $ (join $ lookup "name_agg" query) 
				let routes = showStringUnslash $ renderRequest $ (join $ lookup "routes" query) 
				let cluster = AggConfig {
					name_agg = name_agg , 
					routes = routes 
				} 
				response <- writeCluster cluster 
				send $ responseBuilder status200 [("Content-Type", "text/plain")] $ renderString response

			["cluster-delete"] -> do
				let query = queryString req 
				let idParam = showStringUnslash $ renderRequest $ join $ lookup "info" query 
				content <- deleteCluster idParam
				send $ responseBuilder status200 [("Content-Type", "text/plain")] $ renderString content

			["package-download"] -> do 
				let query = queryString req 
				let idParam_link = showStringUnslash $ renderRequest $ join $ lookup "info" query 
				let idParam_lang = showStringUnslash $ renderRequest $ join $ lookup "lang" query 
				response <- writePackage idParam_link idParam_lang  
				send $ responseBuilder status200 [("Content-Type", "text/plain")] $ renderString response

			["run-command"] -> do
				let query = queryString req 
				let command = showStringUnslash $ renderRequest $ (join $ lookup "command" query) 
				(a,b,c) <- readCreateProcessWithExitCode (shell command) ""				
				send $ responseBuilder status200 [("Content-Type", "text/plain")] $ renderString b

			["clear"] -> do
				let query = queryString req 
				let idParam = showStringUnslash $ renderRequest $ join $ lookup "info" query 
				v <- clearTool idParam
				send $ responseBuilder status200 [("Content-Type", "text/plain")] $ renderString $ show v							

			["install"] -> do
				
				let query = queryString req 
				let idParam_link = showStringUnslash $ renderRequest $ join $ lookup "link" query 
				let idParam_lang = showStringUnslash $ renderRequest $ join $ lookup "lang" query 
				e <- exe_recipe	idParam_link idParam_lang  
				send $ responseBuilder status200 [("Content-Type", "text/plain")] $ renderString $ show e

main = do
	putStrLn $ "Running on => localhost:3000 "
	server 
				
-- eof 
