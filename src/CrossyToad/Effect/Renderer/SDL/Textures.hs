{-# LANGUAGE TemplateHaskell #-}

module CrossyToad.Effect.Renderer.SDL.Textures where

import           Control.Lens
import           Linear.V4
import qualified SDL
import qualified SDL.Font as Font
import qualified SDL.Image as Image

import           CrossyToad.Effect.Renderer.Asset (Asset)
import qualified CrossyToad.Effect.Renderer.Asset as Asset
import           CrossyToad.Effect.Renderer.SDL.Texture (Texture)
import qualified CrossyToad.Effect.Renderer.SDL.Texture as Texture

data Textures = Textures
  { _titleSprite :: Texture
  , _toad :: Texture
  , _toad2 :: Texture
  , _car :: Texture
  }

makeClassy ''Textures

fromAsset :: Asset -> Textures -> Texture
fromAsset Asset.TitleSprite = view titleSprite
fromAsset Asset.Toad = view toad
fromAsset Asset.Toad2 = view toad2
fromAsset Asset.Car = view car

loadTextures :: SDL.Renderer -> IO Textures
loadTextures renderer = do
    let white = (V4 0xff 0xff 0xff 0xff)
    titleFont <- Font.load "assets/font/PrincesS AND THE FROG.ttf" 80
    titleSpriteTexture <- Font.blended titleFont white " CROSSY TOAD "
      >>= toTexture
      >>= Texture.fromSDL

    toadSprite <- Image.loadTexture renderer "assets/sprite/toad.png"
      >>= Texture.fromSDL
    toad2Sprite <- Image.loadTexture renderer "assets/sprite/toad2.png"
      >>= Texture.fromSDL
    carSprite <- Image.loadTexture renderer "assets/sprite/car.png"
      >>= Texture.fromSDL

    pure $ Textures
      { _titleSprite = titleSpriteTexture
      , _toad = toadSprite
      , _toad2 = toad2Sprite
      , _car = carSprite
      }
  where
    toTexture surface = SDL.createTextureFromSurface renderer surface
