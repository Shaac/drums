module Score (Measures (..), Score (..), showMeasures) where

import Duration (Duration)
import Note     (Note)


---------------
-- Structure --
---------------

-- Represent the work in progress.
data Score a = Score {
    title :: String,
    score :: a
}

instance Functor Score where
  fmap f s = s { score = f (score s) }


type Measure = ([(Duration, [Note])], [(Duration, [Note])])

data Measures = Simple [Measure]
              | Volta (Measure, [Measure])
              | DalSegno [(Measures, Int)]
              deriving Eq

showMeasures :: (Measure -> String) -> (Measures, Int) -> String
showMeasures s (Simple l, 1)     = concatMap s l
showMeasures s (Simple l, n)     = "        \\repeat percent " ++
                                   show n ++ " {\n" ++ concatMap s l
                                   ++ "        }\n"
showMeasures s (Volta (m, l), n) = "        \\repeat volta " ++
                                   show n ++ "\n" ++ s m ++
                                   "        \\alternative {\n" ++
                                   concatMap (("            {" ++) .
                                   (++ "            }\n") . s) l ++
                                   "        }\n"
showMeasures s (DalSegno m, _)   = "        \\mark \\markup { \\musicglyph"
                                   ++ "#\"scripts.segno\" }\n" ++
                                   concatMap (showMeasures s) m ++
                                   "        \\mark \\markup { \\musicglyph"
                                   ++ "#\"scripts.segno\" }\n"
