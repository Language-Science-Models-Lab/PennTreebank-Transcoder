# Penn Treebank Transcoder README
# by Joseph Nunn

See LICENSE file

About
-----

This project takes Penn Treebank data (right now only the first directory of the wsj data), preprocesses it with a chain of jeisner's Treebank scripts, and then runs a custom compiler front end, a Flex and Bison based scanner and parser, to transform the sentence data into type annotated lambda terms, which we will be using in a prolog-based learner we are still working on.

Building the transcoder
-----------------------
You will need Flex and Bison installed to run 'make', you will need Perl installed and a Bash shell to run the scripts.  You may also need some C library dependencies as requested in the parser or scanner files.

Makefile will build the executable 'ptrans' by just using 'make'.
You may want to change the default environment depending on your OS in that file.

Repository includes several important scripts:

run-tests.pl   
------------
This script first builds the ptrans executable, then tests it using the tests directory contents.  If you are adding rules to the grammar, please add input and output test files which verify your added grammar rule gives the desired output and run the tests to make sure everything works!

Note, not all tests are grammatical structures mapped correctly to their sentences, check the input files to see the actual structure, do not reply on your knowledge of English to guesstimate the input structure of test sentences.  Sean Fulop swears he will fix the mess one day :)

preprocess.sh
-------------
This script makes use of Jeff Eisner's https://github.com/jeisner/treebank-scripts project to preprocess the Penn Treebank text data prior to running the ptrans transformation.  You should create a symbolic link to Jeff's treebank-scripts in the root of this project and/or edit its location in preprocess.sh.  

You may wish to change the default Treebank location or make a symbolic to where you have the Treebank installed, the default symbolic link location is data/Treebank.  

Output file formatted.in goes to data/preprocessed.

run-data.pl
-----------
This script first builds the ptrans executable, then takes the preprocessed data, formatted.in, the result of running the above script, in the specified data/preprocessed directory and runs the ptrans transformation on it, leaving the result in data/parsed directory.  You may wish to edit the directory locations in this script.

The result of running run-data.pl will be the generation of a formatted.out file in data/parsed directory that is suitable as input to the LambekUnification-Learner project.
