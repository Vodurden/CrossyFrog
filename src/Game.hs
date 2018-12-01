module Game where

import           CrossyToad
import           CrossyToad.Runner

import           CrossyToad.Env (Env(..))
import qualified CrossyToad.Scene.Scene as Scene
import qualified CrossyToad.Effect.Input.SDL.SDL as SDLInput
import qualified CrossyToad.Effect.Renderer.SDL.SDL as SDLRenderer
import qualified CrossyToad.Effect.Time.SDL.SDL as SDLTime

main :: IO ()
main = do
  sceneEnv <- Scene.initialize
  sdlInputEnv <- SDLInput.initialize
  sdlRendererEnv <- SDLRenderer.initialize
  sdlTimeEnv <- SDLTime.initialize
  let cfg = Env
            { _sceneEnv = sceneEnv
            , _sdlInputEnv = sdlInputEnv
            , _sdlRendererEnv = sdlRendererEnv
            , _sdlTimeEnv = sdlTimeEnv
            }

  runCrossyToad cfg mainLoop