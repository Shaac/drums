module Analyse (analyse) where

import Data.List     (group, sort)
import Control.Arrow (first, (***), (&&&))

import Duration (Duration, fromFractional, guess)


------------------------
-- Exported functions --
------------------------

-- | Analyse a list of real notes and organise them with regular durations.
analyse :: (RealFrac a, Ord a) => [(a, b)] -> [(Duration, [b])]
analyse = uncurry zip . (first $ map fromFractional . treat) . unzip . join
  where
    treat = lastNote . detect . normalise . equalise . drop 1


---------------------
-- Local functions --
---------------------

-- Give a duration to last note, so that it lasts until the end of a mesure.
lastNote :: RealFrac a => [a] -> [a]
lastNote xs = xs ++ [1 - ((snd :: (Int, a) -> a) $ properFraction $ sum xs)]

-- Detect the notes durations.
detect :: RealFrac a => [(a, a)] -> [Rational]
detect = map (toRational) . guess . map snd

-- Normalise the duration list so that it represents the fraction of a measure.
normalise :: RealFrac a => [(a, a)] -> [(a, a)]
normalise xs = map ((/ norm) *** (/ norm)) xs
  where
    norm     = let x = majority (map fst xs) in x * (closest $ 3 / x)
    majority = snd . maximum . map (length &&& head) . group . sort
    closest x
      | x <= 2    = max 1 $ fromInteger $ round x
      | otherwise = 2 * (closest (x / 2))

-- Equalise an integer list: close values next to each other are leveled.
-- The original values are kept aside.
equalise :: (Fractional a, Ord a) => [a] -> [(a, a)]
equalise durations = zip (aux durations) durations
  where
    aux []  = []
    aux xs  = let (similar, rest) = cut xs in level similar ++ (aux rest)
    cut l   = span ((< 0.2) . abs . (1 -) . (/ (head l))) l
    level l = let s = length l in replicate s $ sum l / (fromIntegral s)

-- Join notes that are close into simultaneous notes.
join :: (Fractional a, Ord a) => [(a, b)] -> [(a, [b])]
join = initialRest . aux
  where
    initialRest xs
      | null (takeWhile ((> 0.5) . fst) xs) = xs
      | otherwise                           = (0, []) : xs
    aux []            = []
    aux (x : xs) = ((+ offset) *** (: map snd simult)) x : aux rest
      where
        (simult, after) = span ((< 0.075) . fst) xs
        rest
          | null after  = []
          | otherwise   = first (+ offset) (head after) : tail after
        offset          = (/ 2) $ sum $ map fst simult
