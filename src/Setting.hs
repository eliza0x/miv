module Setting where

import qualified Data.Yaml as Y
import Data.HashMap.Lazy hiding (map)
import qualified Data.HashMap.Lazy as HM
import Data.ByteString hiding (empty)
import Data.Maybe (fromMaybe)
import Data.List (sortBy)
import Data.Function (on)

import qualified Plugin as P
import Config
import qualified SettingI as SI

data Setting =
     Setting { plugin         :: [P.Plugin]
             , config         :: Maybe Config
             , filetypeScript :: HashMap String [String]
             , beforeScript   :: [String]
             , afterScript    :: [String]
             , filetypeDetect :: HashMap String String
     } deriving (Eq, Show)

decodeSetting :: ByteString -> Maybe Setting
decodeSetting = fmap toSetting . Y.decode

toSetting :: SI.SettingI -> Setting
toSetting s
  = Setting { plugin = sortWith P.name $ maybe [] (foldlWithKey' (\a k v -> P.toPlugin k v : a) []) (SI.plugin s)
            , config = SI.config s
            , filetypeScript = maybe empty (HM.map lines) (SI.filetypeScript s)
            , beforeScript = lines $ fromMaybe "" (SI.beforeScript s)
            , afterScript = lines $ fromMaybe "" (SI.afterScript s)
            , filetypeDetect = fromMaybe empty (SI.filetypeDetect s)
  }

sortWith :: Ord b => (a -> b) -> [a] -> [a]
sortWith = sortBy . on compare
