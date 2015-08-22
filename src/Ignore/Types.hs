module Ignore.Types where

import Path
import qualified Data.Text as T

-- | VCS type
data VCS
   = VCSGit
   | VCSMercurial
   | VCSDarcs
   deriving (Show, Eq)

-- | An ignore file
data IgnoreFile
   = IgnoreFile
   { if_vcs :: VCS
   , if_data :: Either (Path Abs File) T.Text
   -- ^ Either a path to a file or an embedded 'T.Text' containing the ignore files data
   } deriving (Show, Eq)

-- | Abstract checker if a file should be ignored
newtype FileIgnoredChecker
    = FileIgnoredChecker { runFileIgnoredChecker :: FilePath -> Bool }

instance Monoid FileIgnoredChecker where
    mempty = FileIgnoredChecker $ const False
    mappend (FileIgnoredChecker a) (FileIgnoredChecker b) =
        FileIgnoredChecker $ \fp -> a fp || b fp
