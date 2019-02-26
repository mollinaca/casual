#!/bin/bash

a="${1}"
b="${2}"

echo "A=${a}"
echo "B=${b}"

if [ "${b}" -gt "${a}" ]; then
    echo "input A(arg1) bigger than B(arg2)" 1>&2
    exit 1
fi    

r=1
while true;
do
    r=$((a%b))
    echo "A mod B = ${r}"
    if [ "${r}" -eq 0 ]; then
        break
    fi
    b="${r}"
done

echo "The gratest common divisor of ${1} and ${2} is ${b}"
