{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE OverloadedStrings #-}
module Ignore.VCS.Mercurial
    ( makeChecker
    , file
    )
where

import Ignore.Builder

import Control.Monad.Trans
import Path
import qualified Data.Text as T

makeChecker :: MonadIO m => [T.Text] -> CheckerBuilderT m ()
makeChecker = go registerRegex

file :: Path Rel File
file = $(mkRelFile ".hgignore")

go :: MonadIO m => (T.Text -> CheckerBuilderT m ()) -> [T.Text] -> CheckerBuilderT m ()
go _ [] = return ()
go register (x : xs)
    | T.null ln = go register xs
    | T.head ln == '#' = go register xs
    | T.toLower ln == "syntax: glob" = go registerGlobGit xs
    | T.toLower ln == "syntax: regexp" = go registerRegex xs
    | otherwise =
        do register ln
           go register xs
    where
      ln = T.strip x
