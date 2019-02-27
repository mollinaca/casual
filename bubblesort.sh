#!/bin/bash

echo "input numbers, end of input, input 'end'."
num=0
declare -a array=() 

while true; do
    echo -n "input elem ${num} : "
    read -r elem

    if [ "${elem}" == "end" ]; then
        break
    fi

    array=("${array[@]}" "${elem}")
    num=$((num+1))
done 

i=0
for e in "${array[@]}"; do
    echo "array[$i] = ${e}"
    (( i++ ))
done

echo
echo "=== start bubble sort==="

for ((j=0;j<${#array[@]};j++)); do
    for ((k=0;k<${#array[@]};k++)); do
        echo "j=${j}, k=${k}, ${array[${j}]}, ${array[${k}]}"
        if [ "${array[$j]}" -gt "${array[$k]}" ]; then
            echo " -> swap"
            t=${array[$j]}
            array[$j]=${array[$k]}
            array[$k]=$t          
        fi
    done

    l=0
    echo -n "list : "
    for e in "${array[@]}"; do
        echo -n "${e} "
        (( l++ ))
    done
    echo

    echo
done

echo
echo "=== bubble sort result ==="
i=0
for e in "${array[@]}"; do
    echo "array[${i}] = ${e}"
    (( i++ ))
done

exit 0
