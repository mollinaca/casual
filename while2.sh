#!/bin/bash

txt=test.txt

line_max=$(wc -l <"${txt}")
line_count=1
while read -r line
do
    printf '\r%10s' "in progress... ${line_count}/${line_max}" 1>&2
    # do something
    sleep 1
    ((line_count++))
done <${txt}
echo 1>&2

echo "end"
exit 0
