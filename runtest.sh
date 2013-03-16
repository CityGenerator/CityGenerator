#!/bin/bash
./tests/runtests.pl && \
perl -MDevel::Cover=+select,^lib/.*\.pm,+ignore,^/,tests/  ./tests/runtests.pl >/dev/null && \
cover -summary
chmod -R 755 cover_db
