binary="test grep grep-openmp grep-parallel"

make clean; make

score=0

for file in $binary; do
    if [[ ! -f "$file" ]]; then
        echo "FAIL: $file not made"
        echo "SCORE: $score/7"
        exit 0
    fi
done


for (( i = 0; i < 4; i++ )); do
    echo "TEST: ./test $i"
    ./test $i > /dev/null
    if [ "$?" -eq 1 ]; then
    ((score+=1))
    else
    echo "  --FAIL!"
    fi
done

for (( i = 0; i < 4; i++ )); do
    echo "TEST: ./test-parallel $i"
    ./test-parallel $i > /dev/null
    if [ "$?" -eq 1 ]; then
    ((score+=1))
    else
    echo "  --FAIL!"
    fi
done

for (( i = 0; i < 4; i++ )); do
    echo "TEST: ./test-openmp $i"
    ./test-openmp $i > /dev/null
    if [ "$?" -eq 1 ]; then
    ((score+=1))
    else
    echo "  --FAIL!"
    fi
done

echo "TEST: grep-parallel is faster than grep"

time_file=$(mktemp)

# Time normal grep
/usr/bin/time -f "%e" -o "$time_file" ./grep instance data/warnpeace.txt help > /dev/null
normal_time=$(cat "$time_file")
/usr/bin/time -f "%e" -o "$time_file" ./grep-parallel instance data/warnpeace.txt help > /dev/null
parallel_time=$(cat "$time_file")
echo "  grep:         ${normal_time}s"
echo "  grep-parallel: ${parallel_time}s"

if awk -v normal="$normal_time" -v parallel="$parallel_time" \
    'BEGIN { exit !(parallel < normal) }'; then

    ((score+=1))

else

    echo "  --FAIL: grep-parallel was not faster than grep"

fi

echo "TEST: grep-parallel is faster than grep"
time_file=$(mktemp)

/usr/bin/time -f "%e" -o "$time_file" ./grep instance data/warnpeace.txt help > /dev/null
normal_time=$(cat "$time_file")
/usr/bin/time -f "%e" -o "$time_file" ./grep-openmp instance data/warnpeace.txt help > /dev/null
parallel_time=$(cat "$time_file")
echo "  grep:         ${normal_time}s"
echo "  grep-openmp: ${parallel_time}s"
if awk -v normal="$normal_time" -v parallel="$parallel_time" \
    'BEGIN { exit !(parallel < normal) }'; then
    ((score+=1))
else
    echo "  --FAIL: grep-openmp was not faster than grep"
fi


echo "TEST: questions.txt is non-empty and contains questions (1) through (N)"
N=3
if [ -f questions.txt ] && [ "$(wc -c < questions.txt)" -gt 200 ]; then
    passed=true
    for ((i=1; i<=N; i++)); do
        if ! grep -q "^($i)" questions.txt; then
            echo "  --FAIL: questions.txt missing ($i)"
            passed=false
        fi
    done
    if $passed; then
        ((score+=1))
    fi
else
    echo "  --FAIL!"
fi

echo "SCORE: $score/15"
