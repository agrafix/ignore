{-# LANGUAGE CPP #-}
module Ignore.Core
    ( findIgnoreFiles
    , buildChecker
    )
where

import Ignore.Builder
import Ignore.Types
import qualified Ignore.VCS.Git as Git
import qualified Ignore.VCS.Mercurial as Hg
import qualified Ignore.VCS.Darcs as Darcs

#if MIN_VERSION_base(4,8,0)
#else
import Control.Applicative
#endif
import Control.Monad.Trans
import Data.Maybe
import Path
import System.Directory (doesFileExist)
import qualified Data.Text as T
import qualified Data.Text.IO as T

-- | Get filename of ignore/boring file for a VCS
getVCSFile :: VCS -> Path Rel File
getVCSFile vcs =
    case vcs of
      VCSDarcs -> Darcs.file
      VCSGit -> Git.file
      VCSMercurial -> Hg.file

-- | Search for the ignore/boring files of different VCSes starting a directory
findIgnoreFiles :: [VCS] -> Path Abs Dir -> IO [IgnoreFile]
findIgnoreFiles vcsList rootPath =
    catMaybes <$> mapM seekVcs vcsList
    where
      seekVcs vcs =
          seek vcs rootPath (getVCSFile vcs)
      seek vcs dir file =
          do let full = dir </> file
                 fp = toFilePath full
             isThere <- doesFileExist fp
             if isThere
             then return $ Just (IgnoreFile vcs (Left full))
             else let nextDir = parent dir
                  in if nextDir == dir
                     then return Nothing
                     else seek vcs nextDir file

-- | Build function that checks if a file should be ignored
buildChecker :: [IgnoreFile] -> IO (Either String FileIgnoredChecker)
buildChecker =
    runCheckerBuilder . mapM_ go
    where
      go file =
          do contents <-
                 case if_data file of
                   Left fp -> liftIO $ T.readFile (toFilePath fp)
                   Right t -> return t
             let lns = T.lines contents
             case if_vcs file of
               VCSDarcs -> Darcs.makeChecker lns
               VCSGit -> Git.makeChecker lns
               VCSMercurial -> Hg.makeChecker lns
