
MARKS=$HOME/tllearning/Data/wsj_add_heads
CORPIN=$HOME/tllearning/Data/mrg
CORPOUT=$HOME/tllearning/Data/preprocessed

cd $CORPIN
perl oneline [0-1]*/*.mrg | perl fixsay | perl markargs | perl canonicalize | perl articulate | perl discardconj -q | perl discardbugs $MARKS/newmarked.bug | perl headify $MARKS/newmarked.mrk | perl headall -l | perl binarize > $CORPOUT/formatted

