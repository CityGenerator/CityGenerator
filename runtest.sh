#!/bin/bash
./testlib/runtests.pl && \
perl -MDevel::Cover=+select,^lib/.*\.pm,+ignore,^/,testlib/,runtests.pl  ./testlib/runtests.pl >/dev/null && \
cover -summary
chmod -R 755 cover_db
