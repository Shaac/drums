import Data.Char          (toUpper)
import System.Environment (getArgs)

import Analyse   (analyse)
import Midi      (open)
import Score     (Score (Score))
import Structure (structure)
import Write     (write)

-------------------
-- Main function --
-------------------

-- | Read a midi file name from the command line and create its corresponding
-- sheet music.
main :: IO ()
main = do
  args <- getArgs
  midi <- open $ args !! 0
  let filename = name args
  let title    = if null (arg args "t") then filename else arg args "t"
  writeFile (filename ++ ".ly") $
    write $ fmap structure $ fmap analyse $ Score title midi


---------------------
-- Local functions --
---------------------

-- Read parameter from command line arguments.
arg :: [String] -> String -> String
arg []       _   = ""
arg [_]      _   = ""
arg (x : xs) s
  | x == '-' : s = head xs
  | otherwise    = arg xs s

-- Get the filename.
name :: [String] -> String
name args = if null outputname then inputname "" (args !! 0) else outputname
  where
    outputname                               = arg args "o"
    inputname acc []                         = acc
    inputname _   ('/' : xs)                 = inputname "" xs
    inputname acc (x : xs)
      | x == '.' && map toUpper xs == "MID"  = acc
      | x == '.' && map toUpper xs == "MIDI" = acc
      | otherwise                            = inputname (acc ++ [x]) xs
