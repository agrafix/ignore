{-# OPTIONS_GHC -F -pgmF htfpp #-}
module Main where

import Test.Framework
import {-@ HTF_TESTS @-} Ignore.VCS.GitSpec
import {-@ HTF_TESTS @-} Ignore.VCS.MercurialSpec

main :: IO ()
main = htfMain htf_importedTests
