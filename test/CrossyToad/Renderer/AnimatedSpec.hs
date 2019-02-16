{-# LANGUAGE TemplateHaskell #-}

module CrossyToad.Renderer.AnimatedSpec where

import           Control.Lens
import           Data.Map.Strict (Map)
import qualified Data.Map.Strict as Map
import           Linear.V2

import           Test.Tasty.Hspec

import           CrossyToad.Geometry.Position
import           CrossyToad.Physics.Direction
import           CrossyToad.Renderer.Animated as Animated
import           CrossyToad.Renderer.Animation (currentFrame)
import           CrossyToad.Renderer.AnimationFrame (AnimationFrame)
import qualified CrossyToad.Renderer.AnimationFrame as AnimationFrame
import qualified CrossyToad.Renderer.Asset.ImageAsset as ImageAsset
import           CrossyToad.Renderer.Clip (HasClip(..))
import           CrossyToad.Renderer.RenderCommand
import           CrossyToad.Renderer.Sprite (Sprite(..), HasSprite(..))
import qualified CrossyToad.Renderer.Sprite as Sprite

data AnimationKey = Idle | Jump
  deriving (Eq, Show, Ord)

data Ent = Ent
  { __position :: !Position
  , __direction :: !Direction
  , __sprite :: !Sprite
  , __animated :: !(Animated AnimationKey)
  }

makeClassy ''Ent

instance HasPosition Ent where position = _position
instance HasDirection Ent where direction = _direction
instance HasSprite Ent where sprite = _sprite
instance HasAnimated Ent AnimationKey where animated = _animated

idleFrame1, idleFrame2 :: AnimationFrame
idleFrame1 = AnimationFrame.mk (V2 0  0) (V2 64 64) 0.5
idleFrame2 = AnimationFrame.mk (V2 64 0) (V2 64 64) 0.5

jumpFrame1, jumpFrame2 :: AnimationFrame
jumpFrame1 = AnimationFrame.mk (V2 0  64) (V2 64 64) 0.5
jumpFrame2 = AnimationFrame.mk (V2 64 64) (V2 64 64) 0.5

testAnimations :: Map AnimationKey [AnimationFrame]
testAnimations = Map.fromList [(Idle, idleAnim), (Jump, jumpAnim)]
  where
    idleAnim :: [AnimationFrame]
    idleAnim = [idleFrame1, idleFrame2]

    jumpAnim :: [AnimationFrame]
    jumpAnim = [jumpFrame1, jumpFrame2]

mkEnt :: Ent
mkEnt = Ent
  { __position = (V2 0 0)
  , __direction = North
  , __sprite = Sprite
    { __imageAsset = ImageAsset.Toad
    , __size = V2 64 64
    }
  , __animated = Animated.mk Idle testAnimations
  }

spec_Sprite_AnimatedSpec :: Spec
spec_Sprite_AnimatedSpec = do
  describe "mk" $ do
    it "should start on the first frame of the initial key" $ do
      let animated' = Animated.mk Idle testAnimations
      animated'^.currentAnimation.currentFrame `shouldBe` idleFrame1

  describe "play" $ do
    it "should switch to the given animation" $ do
      let animated' = Animated.mk Idle testAnimations
      let jumpAnim = Animated.play Jump animated'
      jumpAnim ^. currentAnimationKey `shouldBe` Jump

  describe "render" $ do
    it "should render the active animation" $ do
      let ent' = mkEnt & animated . currentAnimationKey .~ Idle
      let drawCommand = render ent'
      (drawCommand ^? _Draw . _3 . _Just) `shouldBe` (Just $ idleFrame1 ^. clip)

    it "should clip the sprite by the size of the active animation frame" $ do
      let ent' = mkEnt & animated . currentAnimationKey .~ Idle
      let drawCommand = render ent'
      (drawCommand ^? _Draw . _3 . _Just) `shouldBe` (Just $ idleFrame1 ^. clip)

    it "should not modify anything other then the texture clip" $ do
      let ent' = mkEnt
      let spriteDraw = Sprite.render ent'
      let animationDraw = render ent'

      -- Strip out the texture changes from both
      let spriteDrawNoTex = spriteDraw & _Draw . _3 .~ Nothing
      let animationDrawNoTex = animationDraw & _Draw . _3 .~ Nothing

      -- If they both match then we know everything else is the same
      spriteDrawNoTex `shouldBe` animationDrawNoTex