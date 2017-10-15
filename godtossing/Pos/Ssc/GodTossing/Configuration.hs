{-# LANGUAGE Rank2Types #-}

module Pos.Ssc.GodTossing.Configuration
    ( GtConfiguration (..)
    , HasGtConfiguration
    , gtConfiguration
    , withGtConfiguration
    , mpcSendInterval
    , mdNoCommitmentsEpochThreshold
    , noReportNoSecretsForEpoch1
    ) where

import           Universum

import           Data.Aeson             (FromJSON (..), genericParseJSON)
import           Data.Reflection        (Given (..), give)
import           Serokell.Aeson.Options (defaultOptions)

import           Data.Time.Units        (Microsecond)
import           Serokell.Util          (sec)

type HasGtConfiguration = Given GtConfiguration

withGtConfiguration :: GtConfiguration -> (HasGtConfiguration => r) -> r
withGtConfiguration = give

gtConfiguration :: HasGtConfiguration => GtConfiguration
gtConfiguration = given

data GtConfiguration = GtConfiguration
    { -- | Length of interval for sending MPC message
      ccMpcSendInterval               :: !Word
      -- | Threshold of epochs for malicious activity detection
    , ccMdNoCommitmentsEpochThreshold :: !Int
      -- | Don't print “SSC couldn't compute seed” for the first epoch.
    , ccNoReportNoSecretsForEpoch1    :: !Bool
    }
    deriving (Show, Generic)

instance FromJSON GtConfiguration where
    parseJSON = genericParseJSON defaultOptions

----------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------

-- | Length of interval during which node should send her MPC message.
mpcSendInterval :: HasGtConfiguration => Microsecond
mpcSendInterval = sec . fromIntegral . ccMpcSendInterval $ gtConfiguration

-- | Number of epochs used by malicious actions detection to check if
-- our commitments are not included in blockchain.
mdNoCommitmentsEpochThreshold :: (HasGtConfiguration, Integral i) => i
mdNoCommitmentsEpochThreshold =
    fromIntegral . ccMdNoCommitmentsEpochThreshold $ gtConfiguration

-- | In the first mainnet version we messed up the calculation of the
-- initial richmen set, and the richmen weren't sending commitments. It has
-- been fixed, but now and for eternity the node prints “SSC couldn't
-- compute seed” after processing blocks from the first epoch. This flag
-- silences that message.
noReportNoSecretsForEpoch1 :: HasGtConfiguration => Bool
noReportNoSecretsForEpoch1 = ccNoReportNoSecretsForEpoch1 $ gtConfiguration
