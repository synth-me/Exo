
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE BlockArguments #-}
{-# LANGUAGE OverloadedStrings #-}


module Report (
	ScheduleState(..),
	AdressConfig(..),
	Report(..),	
	ConfigType(..),
	InputData(..),
	logTemplate, 
	GenericAggregator(..),
	PluginSource(..),
	AnomalySource(..),
	Recipe(..),
	AggConfig(..),
) where 

import Data.ByteString.Lazy as BLU hiding (find,putStrLn,filter,map,head,hGetContents)
import GHC.Generics
import Data.Aeson hiding (Success)
import System.IO
import Control.Monad
import Text.Regex.TDFA
import Data.Text as T hiding(filter,map,head,find)
import Data.Aeson hiding (Success)
import Data.Aeson.BetterErrors (
	Parse,parse, ParseError',key, asString, asIntegral, 
	withRealFloat,
	asRealFloat,
	displayError',
	ParseError,
	eachInArray
	)

data AdressConfig = AdressConfig {
	interface_address :: String ,
	mqtt_address :: String 
} deriving(Show,Generic,Eq)

instance FromJSON AdressConfig 
instance ToJSON AdressConfig

data ScheduleState = ScheduleState {
	name_schedule :: String ,
	mode :: String ,
	time :: Float , 
	message_notify :: String ,
	path_log :: String 
} deriving(Show,Generic,Eq)

instance FromJSON ScheduleState 
instance ToJSON ScheduleState

data Recipe = Recipe {

		package_name :: String ,
		dependencies :: [String], 
		package_aggr :: [AggConfig] ,
		package_plugin_config :: [ConfigType]

} deriving(Show,Generic,Eq)

data AggConfig = AggConfig {
		name_agg :: String , 
		routes :: String
} deriving(Show,Generic,Eq)

data PluginSource = PluginSource {
	name_plugin :: String,
	bytes_plugin :: String 
} deriving(Show,Generic,Eq)

data AnomalySource = AnomalySource {
	name_anomaly :: String,
	bytes_anomaly :: String	
} deriving(Show,Generic,Eq)

data GenericAggregator = GenericAggregator {
		name_log :: String , 
		current_data :: [(String,Float)]
} deriving(Show,Generic,Eq)

data InputData = InputData {
		input_data :: String
} deriving(Show,Generic)
		
data ConfigType = ConfigType {
		name_module :: String , 
		agg_route :: [String] ,
		script_path :: String
} deriving(Show,Generic,Eq)

data GarbageData = GarbageData {
		exclude :: String 	
} deriving(Show,Generic,Eq)

data Report = Report {
	warnKind::String,
	reviewStatus::String,
	logBody::[String]	
} deriving (Show,Generic)

instance FromJSON AggConfig
instance ToJSON AggConfig

instance FromJSON GenericAggregator
instance ToJSON GenericAggregator

instance FromJSON Recipe
instance ToJSON Recipe

instance FromJSON AnomalySource
instance ToJSON AnomalySource

instance FromJSON PluginSource
instance ToJSON PluginSource

instance FromJSON Report
instance ToJSON Report

instance FromJSON ConfigType
instance ToJSON ConfigType

instance FromJSON InputData
instance ToJSON InputData

instance FromJSON GarbageData
instance ToJSON GarbageData

logTemplate :: [Char] -> String -> [String] -> Report
logTemplate "+" x y =  Report { warnKind = x, reviewStatus = "Success"  ,logBody = y}
logTemplate "-" x y =  Report { warnKind = x, reviewStatus = "Failure"  ,logBody = y}
logTemplate "w" x y =  Report { warnKind = x, reviewStatus = "Warning"  ,logBody = y}
logTemplate "r" x y =  Report { warnKind = x, reviewStatus = "Redirect" ,logBody = y}

-- eof 

