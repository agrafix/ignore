module Main where

import Ignore

import Path
import System.Environment
import System.Directory

main :: IO ()
main =
    do dir <- getCurrentDirectory >>= parseAbsDir
       ignoreFiles <- findIgnoreFiles [VCSGit, VCSMercurial, VCSDarcs] dir
       checker <- buildChecker ignoreFiles
       case checker of
           Left err -> error err
           Right (FileIgnoredChecker isFileIgnored) ->
                  putStrLn $
                    "Main.hs is "
                    ++ (if isFileIgnored "Main.hs"
                        then "ignored" else "not ignored")
