ignore
=====

[![Build Status](https://travis-ci.org/agrafix/ignore.svg)](https://travis-ci.org/agrafix/ignore)

## Intro

Hackage: [ignore](http://hackage.haskell.org/package/ignore)

Library and tiny tool for working with ignore files of different version control systems.

## Library Usage

```haskell
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
```

## Commandline Usage

Run in any project under version control to check if a file is ignored or not.

```bash
$ ignore foo~ dist/bar distinct
File foo~ IGNORED
File dist/foo IGNORED
File distinct not ignored
```

## Install

* Using cabal: `cabal install ignore`
* From Source: `git clone https://github.com/agrafix/ignore.git && cd ignore && cabal install`
* Using stack: `git clone https://github.com/agrafix/ignore.git && cd ignore && stack build`
