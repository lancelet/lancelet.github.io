{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

module BlogEntry
  ( loadAllBlogEntries,
    blogEntryToHtml,
    tempBlogEntryCompleteHtml,
  )
where

import CMark
  ( Node (Node),
    NodeType
      ( BLOCK_QUOTE,
        CODE,
        CODE_BLOCK,
        CUSTOM_BLOCK,
        CUSTOM_INLINE,
        DOCUMENT,
        EMPH,
        HEADING,
        HTML_BLOCK,
        HTML_INLINE,
        IMAGE,
        ITEM,
        LINEBREAK,
        LINK,
        LIST,
        PARAGRAPH,
        SOFTBREAK,
        STRONG,
        TEXT,
        THEMATIC_BREAK
      ),
    commonmarkToNode,
    nodeToHtml,
    optNormalize,
    optSmart,
  )
import Control.Monad.Catch (Exception, MonadThrow (throwM))
import Control.Monad.IO.Class (MonadIO (liftIO))
import Data.Functor ((<&>))
import Data.List (find, uncons)
import Data.String (IsString (fromString))
import Data.Text (Text, lines, pack, strip, unlines, unpack)
import Data.Text.Encoding (encodeUtf8)
import Data.Text.IO (readFile)
import Data.Yaml (ParseException, decodeEither')
import Debug.Trace (trace)
import GHC.Generics (Generic)
import Path (Abs, Dir, File, Path, fileExtension, toFilePath)
import Path.IO (listDirRecur)
import Text.Blaze.Html (Html, (!))
import qualified Text.Blaze.Html5 as Html
import qualified Text.Blaze.Html5.Attributes as Attr
import Text.HTML.TagSoup (Tag (TagClose, TagOpen, TagText), parseTags)
import Types (BlogEntrySrc (BlogEntrySrc, post))
import Prelude hiding (lines, readFile, unlines)

---- Loading and Parsing Blog Entries -----------------------------------------

-- | Exceptions that can occur when parsing a blog entry.
data BlogEntryException
  = MetadataSplitFailed
  | YamlParseFailed ParseException
  deriving (Show, Generic, Exception)

-- | Load all blog entries.
--
-- This recursively searches the provided directory for Markdown files and
-- parses them into YAML and Markdown, and returns them as a list of blog
-- entries.
loadAllBlogEntries ::
  (MonadIO m, MonadThrow m) =>
  Path Abs Dir ->
  m [BlogEntrySrc]
loadAllBlogEntries in_dir =
  liftIO (listMarkdownFilesRecur in_dir) >>= mapM loadBlogEntry

-- | Load a blog entry.
--
-- This returns the post's metadata and a CommonMark Node.
loadBlogEntry ::
  (MonadIO m, MonadThrow m) =>
  Path Abs File ->
  m BlogEntrySrc
loadBlogEntry in_file = do
  -- Split into YAML metadata and Markdown text sections.
  maybe_bpt <- liftIO $ loadBlogEntryText in_file
  (metadata_text, markdown_text) <-
    case maybe_bpt of
      Nothing -> throwM MetadataSplitFailed
      Just value -> pure value

  -- Decode the post metadata.
  post_metadata <- case decodeEither' (encodeUtf8 metadata_text) of
    Left parse_exception -> throwM $ YamlParseFailed parse_exception
    Right post_metadata -> pure post_metadata

  -- Decode the Markdown.
  let node = commonmarkToNode [optNormalize, optSmart] markdown_text

  -- Return the blog entry source.
  pure $ BlogEntrySrc in_file post_metadata node

-- | Load a raw blog post. This returns the YAML header metadata and the
--   markdown text.
loadBlogEntryText :: Path Abs File -> IO (Maybe (Text, Text))
loadBlogEntryText in_file = readFile (toFilePath in_file) <&> splitYamlMetadata

-- | Recursively list all Markdown (.md) files in a directory.
listMarkdownFilesRecur :: Path Abs Dir -> IO [Path Abs File]
listMarkdownFilesRecur input_dir = do
  (_dirs, files) <- listDirRecur input_dir
  let isMarkdownFile f = (fileExtension f <&> pack) == Just ".md"
  pure $ filter isMarkdownFile files

-- | Split a text string into a YAML metadata block, and subsequent content.
--
-- The YAML metadata block must exist and must be at the start of the `Text`.
-- YAML separators (`"---"`) must be on their own line, but can have
-- whitespace surround them.
splitYamlMetadata :: Text -> Maybe (Text, Text)
splitYamlMetadata input =
  case uncons (lines input) of
    Nothing -> Nothing
    Just (head_line, tail_lines) ->
      if not $ isYamlSeparatorLine head_line
        then Nothing
        else case breakDelimPred isYamlSeparatorLine tail_lines of
          Nothing -> Nothing
          Just (startYaml, markdown) ->
            Just (unlines startYaml, unlines markdown)

-- \ Break a list of items at a delimiter predicate.
--
-- If the delimiter predicate is not found, the function returns Nothing. If
-- the predicate is found, the function returns all items before the first
-- item that satifies the predicate, and all items after that item, excluding
-- the predicate item itself.
breakDelimPred :: (a -> Bool) -> [a] -> Maybe ([a], [a])
breakDelimPred pred_fn xs =
  let (before_pred, from_pred) = break pred_fn xs
   in case from_pred of
        h : after_pred | pred_fn h -> Just (before_pred, after_pred)
        _ -> Nothing

-- | Return `true` if a line of text is a YAML separator.
--
-- A line is a YAML separator if, when stripped of whitespace, it contains the
-- characters `"---"`.
isYamlSeparatorLine :: Text -> Bool
isYamlSeparatorLine txt = strip txt == "---"

---- Rendering Blog Entries ---------------------------------------------------

tempBlogEntryCompleteHtml :: BlogEntrySrc -> Html
tempBlogEntryCompleteHtml blogEntrySrc =
  Html.html $
    Html.body $
      mconcat
        [ blogEntryToHtml blogEntrySrc
        ]

-- | Convert a blog entry to HTML.
blogEntryToHtml :: BlogEntrySrc -> Html
blogEntryToHtml = blogEntryNodeToHtml . post

-- | Convert a CommonMark `Node` to HTML.
blogEntryNodeToHtml :: Node -> Html
blogEntryNodeToHtml node =
  case node of
    Node _ DOCUMENT ns -> concatNodes ns
    Node _ THEMATIC_BREAK _ -> mempty
    Node _ PARAGRAPH ns ->
      Html.p
        ! Attr.class_ "blog_p"
        $ concatNodes ns
    Node _ BLOCK_QUOTE _ -> undefined
    Node _ (HTML_BLOCK block) _ -> htmlBlock block
    Node _ (CUSTOM_BLOCK _ _) _ -> undefined
    Node _ (CODE_BLOCK _ _) _ -> undefined
    Node _ (HEADING _) _ -> undefined
    Node _ (LIST _) _ -> undefined
    Node _ ITEM _ -> undefined
    Node _ (TEXT _) [] -> Html.text (nodeToHtml [] node)
    Node _ (TEXT _) _ -> undefined
    Node _ SOFTBREAK _ -> Html.text " "
    Node _ LINEBREAK _ -> undefined
    Node _ (HTML_INLINE _) _ -> undefined
    Node _ (CUSTOM_INLINE _ _) _ -> undefined
    Node _ (CODE _) _ -> undefined
    Node _ EMPH _ -> undefined
    Node _ STRONG _ -> undefined
    Node _ (LINK url "") ns ->
      Html.a
        ! Attr.href (fromString . unpack $ url)
        ! Attr.class_ "blog_external_link"
        $ concatNodes ns
    Node _ (LINK _ _) _ -> undefined
    Node _ (IMAGE _ _) _ -> undefined

-- | Concatenate HTML `Node`s into a single HTML document.
concatNodes :: [Node] -> Html
concatNodes = mconcat . fmap blogEntryNodeToHtml

-- | Create an HTML block from recognized HTML and custom elements.
htmlBlock :: Text -> Html
htmlBlock block =
  case parseTags block of
    tags@(TagOpen "displaymath" _ : _) ->
      displayMath tags
    _ ->
      undefined

-- | Process a `displaymath` custom node.
displayMath :: [Tag Text] -> Html
displayMath tags =
  case tags of
    TagOpen "displaymath" attrs : TagText math : TagClose "displaymath" : _ ->
      let id_attr =
            case find (\(key, _) -> key == "id") attrs of
              Just (_, id_value) -> Attr.id (fromString . unpack $ id_value)
              Nothing -> mempty
       in Html.div
            ! id_attr
            ! Attr.class_ "blog_displaymath"
            $ Html.text
            $ mconcat ["\\[", strip math, "\\]"]
    x ->
      trace (show x) undefined