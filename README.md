ignore
=====

[![Build Status](https://travis-ci.org/agrafix/ignore.svg)](https://travis-ci.org/agrafix/ignore)
[![Hackage](https://img.shields.io/hackage/v/ignore.svg)](http://hackage.haskell.org/package/ignore)

## Intro

Hackage: [ignore](http://hackage.haskell.org/package/ignore)
Stackage: [ignore](https://www.stackage.org/package/ignore)

Handle ignore files of different VCSes

## Cli Usage: ignore

```sh
$ ignore --help
The ignore tool
(c) 2015 Alexander Thiemann

Tiny tool to check if a file in a repo is ignored by a VCS

Usage: ignore [--help|-h] file1 file2 file3 ... fileN

```

## Library Usage Example

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

## Install

* Using cabal: `cabal install ignore`
* Using Stack: `stack install ignore`
* From Source (cabal): `git clone https://github.com/agrafix/ignore.git && cd ignore && cabal install`
* From Source (stack): `git clone https://github.com/agrafix/ignore.git && cd ignore && stack build`


## Misc

### Supported GHC Versions


### License

Released under the BSD3 license.
(c) 2015 Alexander Thiemann
