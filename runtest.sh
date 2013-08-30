#!/bin/bash

if [[ "$1" == "profile" ]] ; then
    echo "profiling code"
    perl -d:NYTProf  ./tests/runtests.pl
    rm -rf nytprof.old || echo "no old to remove"
    mv nytprof nytprof.old
    nytprofhtml --open
 
elif [[ "$1" == "full" || "$1" == "all" ]]  ;then
    echo "full test, coverage and profiling"
    rm -rf cover_db || echo "no old cover to remove"
    rm -rf nytprof || echo "no old nytprof to remove"
#    perl -d:NYTProf  ./tests/runtests.pl  && \
    perl -MDevel::Cover=+select,^lib/.*\.pm,+ignore,^/,tests/  ./tests/runtests.pl >/dev/null && \
    cover -summary && \
    chmod -R 755 cover_db && \

    nytprofhtml --open

elif [[ "$1" == "cover" ]] ;then
    echo " checking code coverage"
    rm -rf cover_db || echo "no old cover to remove"
    HARNESS_PERL_SWITCHES=-MDevel::Cover=+ignore,^/,tests/  prove tests/*.pm
    cover -summary 
    chmod -R 755 cover_db

else
    echo "quick test"
    prove tests/*.pm --timer --normalize -t -w --norc -s -j9 -l lib/

fi

