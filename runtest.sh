#!/bin/bash

if [[ "$1" == "profile" ]] ; then
    echo "profiling code"
    perl -d:NYTProf  ./tests/runtests.pl
    rm -rf nytprof.old || echo "no old to remove"
    mv nytprof nytprof.old
    nytprofhtml --open
 
elif [[ "$1" == "full" || "$1" == "all" ]]  ;then
    echo "full test, coverage and profiling"

#    perl -d:NYTProf  ./tests/runtests.pl  && \
    perl -MDevel::Cover=+select,^lib/.*\.pm,+ignore,^/,tests/  ./tests/runtests.pl >/dev/null && \
    cover -summary && \
    chmod -R 755 cover_db && \
    rm -rf nytprof.old || echo "no old to remove"
    mv nytprof nytprof.old
    nytprofhtml --open

elif [[ "$1" == "cover" ]] ;then
    echo " checking code coverage"

    perl -MDevel::Cover=+select,^lib/.*\.pm,+ignore,^/,tests/  ./tests/runtests.pl >/dev/null && \
    cover -summary && \
    chmod -R 755 cover_db

else
    echo "quick test"
    perl ./tests/runtests.pl 


fi

