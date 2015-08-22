module Main where

import Ignore

import Path
import System.Environment
import System.Directory

main :: IO ()
main =
    do args <- getArgs
       case args of
         ("--help": _) -> help
         ("-h": _) -> help
         [] -> help
         files -> run files

help :: IO ()
help =
    do putStrLn "The ignore tool"
       putStrLn "(c) 2015 Alexander Thiemann"
       putStrLn ""
       putStrLn "Tiny tool to check if a file in a repo is ignored by a VCS"
       putStrLn ""
       putStrLn "Usage: ignore [--help|-h] file1 file2 file3 ... fileN"

run :: [FilePath] -> IO ()
run files =
    do dir <- getCurrentDirectory >>= parseAbsDir
       ignoreFiles <- findIgnoreFiles [VCSGit, VCSMercurial, VCSDarcs] dir
       case ignoreFiles of
         [] -> putStrLn "No ignore files found. Maybe add one? .gitignore, .hgignore, ...?"
         _ ->
             do checker <- buildChecker ignoreFiles
                case checker of
                  Left err -> putStrLn $ "Failed to handle ignore/boring file: " ++ err
                  Right (FileIgnoredChecker check) ->
                      mapM_ (\f -> putStrLn $ "File " ++ f ++ " " ++ if check f then "IGNORED" else "not ignored") files
