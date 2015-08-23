{-# LANGUAGE CPP #-}
{-# LANGUAGE TemplateHaskell #-}
module Ignore.VCS.Darcs
    ( makeChecker
    , file
    )
where

import Ignore.Builder

import Control.Monad.Trans
import Path
import qualified Data.Text as T

#ifdef NO_PCRE
makeChecker :: MonadIO m => [T.Text] -> CheckerBuilderT m ()
makeChecker _ =
    liftIO $
    do putStrLn "The ignore library was compiled with the without-pcre flag."
       putStrLn "This means that we can not handle darcs boring files for now."
#else
makeChecker :: MonadIO m => [T.Text] -> CheckerBuilderT m ()
makeChecker = go
#endif

file :: Path Rel File
file = $(mkRelDir "_darcs/prefs") </> $(mkRelFile "boring")

go :: MonadIO m => [T.Text] -> CheckerBuilderT m ()
go [] = return ()
go (x : xs)
    | T.null ln = go xs
    | T.head ln == '#' = go xs
    | otherwise =
        do registerRegex ln
           go xs
    where
      ln = T.strip x
