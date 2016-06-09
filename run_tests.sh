if [ -f ./score_tests.native ]; then
    ./score_tests.native
else
    ./score_tests.byte
fi
