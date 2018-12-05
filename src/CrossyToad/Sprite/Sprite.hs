{-# LANGUAGE TemplateHaskell #-}

module CrossyToad.Sprite.Sprite
  ( Sprite(..)
  , HasSprite(..)
  , render
  , render'
  ) where

import Control.Lens
import Control.Monad (mfilter)

import CrossyToad.Effect.Renderer.Renderer
import CrossyToad.Effect.Renderer.ImageAsset (ImageAsset, HasImageAsset(..))
import           CrossyToad.Effect.Renderer.RenderCommand (RenderCommand(..))
import CrossyToad.Effect.Renderer.Dimensions
import CrossyToad.Effect.Renderer.PixelClip (PixelClip(..))
import CrossyToad.Physics.Position
import CrossyToad.Physics.Direction

data Sprite = Sprite
  { __imageAsset :: ImageAsset
  , __dimensions :: Dimensions
  } deriving (Eq, Show)

makeClassy ''Sprite

instance HasImageAsset Sprite where
  imageAsset = _imageAsset

instance HasDimensions Sprite where
  dimensions = _dimensions

render' ::
  ( HasPosition ent
  , HasDirection ent
  , HasSprite ent
  ) => ent -> RenderCommand
render' ent = do
  let pos = truncate <$> ent ^. position
  let rotation = mfilter (/= 0) (Just $ degrees (ent^.direction))
  let screenClip = PixelClip pos (ent ^. sprite . dimensions)
  Draw (ent^.sprite.imageAsset)
       rotation
       Nothing
       (Just screenClip)

render ::
  ( Renderer m
  , HasPosition ent
  , HasDirection ent
  , HasSprite ent
  ) => ent -> m ()
render ent = do
  let pos = truncate <$> ent ^. position
  let rotation = mfilter (/= 0) (Just $ degrees (ent^.direction))
  let screenClip = PixelClip pos (ent ^. sprite . dimensions)
  draw (ent^.sprite.imageAsset)
       rotation
       Nothing
       (Just screenClip)
