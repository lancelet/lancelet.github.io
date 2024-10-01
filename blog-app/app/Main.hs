{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}

module Main (main) where

import BlogEntry (loadAllBlogEntries, tempBlogEntryCompleteHtml)
import Data.Text (pack)
import Data.Text.IO (putStrLn)
import Data.Text.Lazy (toStrict)
import Path (parent, reldir, (</>))
import Path.IO (getCurrentDir)
-- import Text.Blaze.Html.Renderer.Pretty (renderHtml)
import Text.Blaze.Html.Renderer.Text (renderHtml)
import Prelude hiding (putStr, putStrLn)

main :: IO ()
main = do
  putStrLn "Hello World"
  parent_dir <- parent <$> getCurrentDir
  let md_dir = parent_dir </> [reldir|posts|]
  entries <- loadAllBlogEntries md_dir
  -- putStrLn . pack . show $ entries
  let htmls = fmap (renderHtml . tempBlogEntryCompleteHtml) entries
  putStrLn . mconcat . fmap toStrict {- . fmap pack -} $ htmls
