if [ -f ./score_tests.native ]; then
    ./score_tests.native -v
else
    ./score_tests.byte -v
fi
