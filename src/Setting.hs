{-# LANGUAGE TemplateHaskell #-}
module Setting where

import Data.Aeson (decode)
import Data.Aeson.TH
import Data.HashMap.Lazy
import Data.ByteString.Lazy

import qualified Plugin as P
import Config
import qualified SettingI as SI

data Setting =
     Setting { plugin         :: Maybe [P.Plugin]
             , config         :: Maybe Config
             , filetypeScript :: Maybe (HashMap String [String])
             , beforeScript   :: Maybe [String]
             , afterScript    :: Maybe [String]
     } deriving (Eq, Show)
$(deriveJSON defaultOptions ''Setting)

decodeSetting :: ByteString -> Maybe Setting
decodeSetting = fmap toSetting . decode

toSetting :: SI.SettingI -> Setting
toSetting s
  = Setting { plugin = fmap (foldlWithKey' (\a k v -> P.toPlugin k v : a) []) (SI.plugin s)
            , config = SI.config s
            , filetypeScript = SI.filetypeScript s
            , beforeScript = SI.beforeScript s
            , afterScript = SI.afterScript s
  }