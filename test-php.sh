#!/bin/sh
#
cat php-full-test-list | while read PTEST LNAME; do make test TESTS=$PTEST 2>&1 | tee make-test-$LNAME.log; done

echo -e "Test\t\tPass\tSkip\tFail" > php-full-test-results.log

cat php-full-test-list | while read PTEST LNAME; do echo $LNAME; egrep '^Tests (passed|failed|skipped)' make-test-$LNAME.log | awk '{print $4}'; done \
	| sed -e 'N;N;N;s/\n/\t/g' | awk '{printf "%s",$1 "\t"; if(length($1) < 8) printf "%s","\t"; print $4 "\t" $2 "\t" $3}'>> php-full-test-results.log

cat php-full-test-list | while read PTEST LNAME; do egrep -H '^Tests borked' make-test-$LNAME.log ; done >> php-full-test-results.log

