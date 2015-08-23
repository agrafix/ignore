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

makeChecker :: MonadIO m => [T.Text] -> CheckerBuilderT m ()
makeChecker = go

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
