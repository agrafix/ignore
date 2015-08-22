{-# OPTIONS_GHC -F -pgmF htfpp #-}
{-# LANGUAGE OverloadedStrings #-}
module Ignore.VCS.MercurialSpec (htf_thisModulesTests) where

import Ignore

import Test.Framework
import qualified Data.Text as T

ignoreFile :: IgnoreFile
ignoreFile =
    IgnoreFile
    { if_vcs = VCSMercurial
    , if_data =
        Right $
        T.unlines
        [ "# comment"
        , "syntax: glob"
        , "dist"
        , "cabal-dev"
        , "*.o"
        , "*.hi"
        , "*.chi"
        , "*.chs.h"
        , ".virthualenv"
        , ".DS_Store"
        , ".cabal-sandbox"
        , "cabal.sandbox.config"
        , "*~"
        , ".stack-work"
        , "syntax: regexp"
        , ".*\\.aux"
        ]
    }

getFileIgnoredChecker :: IO (FilePath -> Bool)
getFileIgnoredChecker =
    do ch <- buildChecker [ignoreFile]
       (FileIgnoredChecker f) <- assertRight ch
       return f

test_parserWorks :: IO ()
test_parserWorks =
    do _ <- subAssert getFileIgnoredChecker
       return ()

test_correctNoSlash :: IO ()
test_correctNoSlash =
    do matcher <- subAssert getFileIgnoredChecker
       assertBool (matcher "foo~")
       assertBool (matcher "dist/foo")
       assertBool (matcher "foo/bar~")
       assertBool (matcher "dist")
       assertBool (not $ matcher "distinct")
       assertBool (not $ matcher "src/foo.hs")
       assertBool (matcher "src/foo.hi")
       assertBool (matcher "cabal.sandbox.config")
       assertBool (not $ matcher "Spock.cabal")
       assertBool (matcher "test.aux")
       assertBool (matcher "foooa/test.aux")
       assertBool (not $ matcher "auxauxaux")
