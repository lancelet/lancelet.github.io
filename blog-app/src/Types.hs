{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE StrictData #-}

module Types
  ( PostId (..),
    Author (..),
    PostMetadata (..),
    BlogEntrySrc (..),
  )
where

import CMark (Node)
import Data.Aeson (FromJSON (parseJSON), withObject, withText, (.:))
import Data.Text (Text)
import Data.Time (Day)
import Path (Abs, File, Path)

---- PostId -------------------------------------------------------------------

newtype PostId = PostId Text
  deriving (Show, Eq, Ord)

instance FromJSON PostId where
  parseJSON = withText "PostId" (pure . PostId)

---- Author -------------------------------------------------------------------

newtype Author = Author Text
  deriving (Show, Eq, Ord)

instance FromJSON Author where
  parseJSON = withText "Author" (pure . Author)

---- PostMetadata -------------------------------------------------------------

data PostMetadata = PostMetadata
  { id :: PostId,
    title :: Text,
    author :: Author,
    tags :: [Text],
    published :: Day,
    updated :: Day
  }
  deriving (Show, Eq)

instance FromJSON PostMetadata where
  parseJSON = withObject "PostMetadata" $ \v ->
    PostMetadata
      <$> v .: "id"
      <*> v .: "title"
      <*> v .: "author"
      <*> v .: "tags"
      <*> v .: "published"
      <*> v .: "updated"

---- BlogEntrySrc -------------------------------------------------------------

-- | Source information for a blog entry.
data BlogEntrySrc = BlogEntrySrc
  { inFile :: !(Path Abs File),
    metadata :: !PostMetadata,
    post :: !Node
  }
  deriving (Eq, Show)
