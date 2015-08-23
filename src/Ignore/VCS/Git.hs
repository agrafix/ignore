{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE OverloadedStrings #-}
module Ignore.VCS.Git
    ( makeChecker
    , file
    )
where

import Ignore.Builder

import Control.Monad.Trans
import Path
import qualified Data.Text as T

makeChecker :: MonadIO m => [T.Text] -> CheckerBuilderT m ()
makeChecker = mapM_ handleLine

file :: Path Rel File
file = $(mkRelFile ".gitignore")

handleLine :: MonadIO m => T.Text -> CheckerBuilderT m ()
handleLine origLn
    | T.null ln = return ()
    | T.head ln == '#' = return ()
    | otherwise = registerGlobGit ln
    where
      ln = T.strip origLn -- TODO: quoted trailing whitespace
