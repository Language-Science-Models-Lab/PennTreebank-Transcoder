#!/bin/bash

# This script uses Marks Treebank processing project to convert Treebank data into parsable format
# by Joseph Nunn and Sean Fulop 2016

# TSCRIPTS must point to a symbolic link or actual directory to Jeff Eisner's Treebank Scripts https://github.com/jeisner/treebank-scripts.git
TSCRIPTS=jeisner-scripts
CORPIN=data/Treebank/parsed/mrg/wsj
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

GUARD=0

for I in ${SCRIPT_LIST[@]}; do
	if [ ! -x "$TSCRIPTS/${I}" ]; then
		echo "$TSCRIPTS/${I} not found or executable" ;
		GUARD=1
	else
		echo "found executable $TSCRIPTS/${I}" ;
	fi
done

if [ $GUARD -eq 1 ]; then
   echo "Not all scripts found or executable, exiting";
   exit 1
fi

#Do the work
perl -I $TSCRIPTS $TSCRIPTS/oneline $CORPIN/[0-1]*/*.mrg | perl -I $TSCRIPTS $TSCRIPTS/${SCRIPT_LIST[0]} | perl -I $TSCRIPTS $TSCRIPTS/${SCRIPT_LIST[1]} | perl -I $TSCRIPTS $TSCRIPTS/${SCRIPT_LIST[2]} | perl -I $TSCRIPTS $TSCRIPTS/${SCRIPT_LIST[3]} | perl -I $TSCRIPTS $TSCRIPTS/${SCRIPT_LIST[4]} -q | perl -I $TSCRIPTS $TSCRIPTS/${SCRIPT_LIST[5]} $TSCRIPTS/newmarked.bug | perl -I $TSCRIPTS $TSCRIPTS/${SCRIPT_LIST[6]} $TSCRIPTS/newmarked.mrk | perl -I $TSCRIPTS $TSCRIPTS/${SCRIPT_LIST[7]} -l | perl -I $TSCRIPTS $TSCRIPTS/${SCRIPT_LIST[8]} > $CORPOUT/formatted.in
