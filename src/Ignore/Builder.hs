{-# LANGUAGE CPP #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE OverloadedStrings #-}
module Ignore.Builder
    ( CheckerBuilderT
    , runCheckerBuilder
    , registerGlob, registerGlobGit, registerRegex
    )
where

import Ignore.Types

import Control.Applicative
import Control.Monad.Writer
#if MIN_VERSION_mtl(2,2,0)
import Control.Monad.Except
#else
import Control.Monad.Error
#endif
import Text.Regex.PCRE.Heavy ((=~))
import qualified Data.Text as T
import qualified Data.Text.Encoding as T
import qualified Text.Regex.PCRE.Heavy as Re
import qualified System.FilePath.Glob as G

#if MIN_VERSION_mtl(2,2,0)
type ErrorT = ExceptT
runErrorT :: ExceptT e m a -> m (Either e a)
runErrorT = runExceptT
#endif

newtype CheckerBuilderT m a
    = CheckerBuilderT { unCheckerBuilderT :: ErrorT String (WriterT FileIgnoredChecker m) a }
      deriving (Monad, Functor, Applicative, Alternative, MonadIO, MonadError String)

runCheckerBuilder :: Monad m => CheckerBuilderT m () -> m (Either String FileIgnoredChecker)
runCheckerBuilder cb =
    do (res, out) <- runWriterT (runErrorT $ unCheckerBuilderT cb)
       case res of
         Left err ->
             return $ Left err
         Right () ->
             return $ Right out

registerGlobGit :: Monad m => T.Text -> CheckerBuilderT m ()
registerGlobGit pat
    | not ("/" `T.isInfixOf` pat) =
        do registerGlob pat
           registerGlob ("**/" <> pat <> "/**")
           registerGlob ("**/" <> pat)
    | otherwise = registerGlob pat

registerGlob :: Monad m => T.Text -> CheckerBuilderT m ()
registerGlob globPattern =
    CheckerBuilderT $
    case G.tryCompileWith G.compDefault (T.unpack globPattern) of
      Left err -> throwError ("Failed to compile glob pattern " ++ T.unpack globPattern ++ ": " ++ err)
      Right pat ->
          do let simplified = G.simplify pat
             lift $ tell $ FileIgnoredChecker (G.matchWith G.matchPosix simplified)

registerRegex :: Monad m => T.Text -> CheckerBuilderT m ()
registerRegex rePattern =
    CheckerBuilderT $
    case Re.compileM (T.encodeUtf8 rePattern) [] of
      Left err -> throwError ("Failed to compile regex pattern " ++ T.unpack rePattern ++ ": " ++ err)
      Right pat ->
          lift $ tell $ FileIgnoredChecker (=~ pat)
