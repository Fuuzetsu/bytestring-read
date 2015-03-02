{-# LANGUAGE OverloadedStrings #-}

module Main (main) where

import Criterion.Main

import Data.ByteString(ByteString)
import qualified Data.ByteString.Char8 as SC

import qualified Data.Text.Encoding as T

import Data.Scientific(toRealFloat)
import Data.String(IsString)

import qualified Data.ByteString.Read as R
import qualified Data.Text.Read as T
import qualified Data.ByteString.Lex.Double as L
import qualified Data.Attoparsec.ByteString.Char8 as A

short :: ByteString
short = "-2342395232123424.3424346343524e3"

long :: ByteString
long = "-234232345678976521345895325678987654321345678987654321345689643213595232123424.34243463435223456789321367899231808534492500740957389523850293482093852039587495203586329850238562834290374029844e3"

checkConsumed :: (IsString a, Eq a) => (v, a) -> v
checkConsumed (d, "") = d
checkConsumed _       = error "not consumed"

bytestringRead :: ByteString -> Double
bytestringRead = maybe (error "parse error") checkConsumed . R.signed R.floating

text :: ByteString -> Double
text = either (const $ error "parse error") checkConsumed . T.signed T.double . T.decodeUtf8

bytestringLexing :: ByteString -> Double
bytestringLexing = maybe (error "parse error") checkConsumed . L.readDouble

attoparsec :: ByteString -> Double
attoparsec = either (const $ error "parse error") id . A.parseOnly (fmap toRealFloat A.scientific)

read' :: ByteString -> Double
read' = read . SC.unpack

doBench :: String -> (ByteString -> Double) -> Benchmark
doBench n f = bgroup n
    [ bench "short" $ nf f short
    , bench "long"  $ nf f long
    ]

main :: IO ()
main = defaultMain
    [ doBench "bytestring-read" bytestringRead
    , doBench "text" text
    , doBench "bytestring-lexing" bytestringLexing
    , doBench "attoparsec" attoparsec
    , doBench "read" read'
    ]