{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE FunctionalDependencies #-}

module CrossyToad.Effect.Task.IO.TaskState where

import Control.Lens
import Data.IORef

import CrossyToad.Effect.Task.Task

data TaskState m = TaskState
  { _tasks :: [Task m ()]
  }

makeClassy ''TaskState

class HasTaskStateIORef m a where
  taskStateRef :: Getter a (IORef (TaskState m))

instance HasTaskStateIORef m (IORef (TaskState m)) where
  taskStateRef = id

mk :: TaskState m
mk = TaskState
  { _tasks = []
  }