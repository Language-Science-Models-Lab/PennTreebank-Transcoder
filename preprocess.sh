#!/bin/bash

# This script uses Marks Treebank processing project to convert Treebank data into parsable format

# by Joseph Nunn and Sean Fulop 2016

# MARKS must point to a symbolic link or actual directory to Jeff Eisner's Treebank Scripts https://github.com/jeisner/treebank-scripts.git
MARKS=jeisner-scripts
CORPIN=data/Treebank/parsed/mrg
CORPOUT=data/preprocessed

# Scripts to be run here, note order is important!, check final perl call to see how scripts are run.
SCRIPT_LIST=( 'fixsay'
			  'markargs'
			  'canonicalize'
			  'articulate'
			  'discardconj'
			  'discardbugs'
			  'headify'
			  'headall'
			  'binarize'
			  )
#CORPIN=$HOME/tllearning/Data/mrg
#CORPOUT=$HOME/tllearning/Data/preprocessed
GUARD=0

for I in ${SCRIPT_LIST[@]}; do
	if [ ! -x "$MARKS/${I}" ]; then
		echo "$MARKS/${I} not found or executable" ;
		GUARD=1
	else
		echo "found executable ${I}" ;
	fi
done

if [ $GUARD -eq 1 ]; then
   echo "Not all scripts found or executable, exiting";
   exit 1
fi

#cd $CORPIN
#perl oneline [0-1]*/*.mrg | perl $MARKS/fixsay | perl $MARKS/markargs | perl canonicalize | perl articulate | perl discardconj -q | perl discardbugs $MARKS/newmarked.bug | perl headify $MARKS/newmarked.mrk | perl headall -l | perl binarize > $CORPOUT/formatted

#perl oneline [0-1]*/*.mrg | perl $MARKS/${SCRIPT_LIST[0]} | perl $MARKS/${SCRIPT_LIST[1]} | perl ${SCRIPT_LIST[2]} | perl ${SCRIPT_LIST[3]} | perl ${SCRIPT_LIST[4]} -q | perl ${SCRIPT_LIST[5]} $MARKS/newmarked.bug | perl ${SCRIPT_LIST[6]} $MARKS/newmarked.mrk | perl ${SCRIPT_LIST[7]} -l | perl ${SCRIPT_LIST[8]} > $CORPOUT/formatted

