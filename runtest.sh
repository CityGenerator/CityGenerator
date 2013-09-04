#!/bin/bash

if [[ "$1" == "profile" ]] ; then
    echo "profiling code"
    perl -d:NYTProf  ./tests/runtests.pl
    rm -rf nytprof.old || echo "no old to remove"
    mv nytprof nytprof.old
    nytprofhtml --open
 
elif [[ "$1" == "cover" ]] ;then
    rm -rf cover_db || echo "no old cover to remove"
    echo -n " checking code coverage"

    if [[ -e "$2" ]] ; then
        echo " of $2"
        HARNESS_PERL_SWITCHES=-MDevel::Cover=+ignore,^/,tests/  prove tests/Test${2##lib/}
        cover -summary|grep "$2\|---\|^File"
    else
        echo
        HARNESS_PERL_SWITCHES=-MDevel::Cover=+ignore,^/,tests/  prove tests/*.pm
        cover -summary 
    fi
    chmod -R 755 cover_db

else
    echo "quick test"
    prove tests/*.pm --timer --normalize -t -w --norc -s -j9 -l lib/

fi

