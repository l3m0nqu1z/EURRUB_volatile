#!/bin/bash
TMP="/tmp/jq.tmp"
[[ ! -f ./quotes.json ]] && curl -s https://yandex.ru/news/quotes/graph_2000.json > ./quotes.json

loading() {
   pid=$!
   spin='-\|/'
   i=0
   while kill -0 $pid 2>/dev/null
   do
      i=$(( (i+1) %4 ))
      printf "\r[${spin:$i:1}] "
      sleep .1
   done
}

main() {
jq -c '.prices[]' quotes.json | grep -oP '\d+\,\d+\.\d+' | sed 's/,/\t/' > $TMP
grep -oP '^\d{10}' $TMP | while read OLD_DATE; do
NEW_DATE=$(date +"%a %d %B %Y %T %p %:::z " --date="@$OLD_DATE")
OLD_DATE+=000
sed -i "s/$OLD_DATE/$NEW_DATE/g" $TMP
done
for (( i=2015; i<=2021; i++ ))
{
echo -n -e "\t$1 $i\t"
grep $1 $TMP | grep $i | awk '{print $8}' | awk -v min=$1 -v max=0 '{if ($1>max) max=$1; if ($1<min) min=$1} END {print max-min}'
} > $TMP.2
VOLATILE=$(awk '{print $3}' $TMP.2 | awk -v min=$1 '{if ($1<min && $1 != 0) min=$1} END {print min}')
grep "$VOLATILE" $TMP.2
}

cleanup() {
rm -f $TMP*
}

#Script's working steps
main $1 & loading
cleanup
