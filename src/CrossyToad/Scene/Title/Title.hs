module CrossyToad.Scene.Title.Title where

import           Control.Lens
import           Data.Foldable (foldl')

import           CrossyToad.Effect.Input.Input
import           CrossyToad.Effect.Renderer.Renderer
import           CrossyToad.Scene.Internal (HasScene, scene)
import qualified CrossyToad.Scene.Internal as Scene
import           CrossyToad.Scene.Title.Intent (Intent(..))
import qualified CrossyToad.Scene.Title.Intent as Intent

stepTitle :: (HasScene ent, Input m, Renderer m) => ent -> m ent
stepTitle ent = do
  events <- getInputEvents
  let intents = Intent.fromInput events
  let nextEnt = foldl' (flip stepIntent) ent intents

  drawTitleText

  pure nextEnt

stepIntent :: (HasScene ent) => Intent -> ent -> ent
stepIntent StartGame = scene .~ Scene.Game
stepIntent Quit = scene .~ Scene.Quit
