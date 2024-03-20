#!/bin/bash

times=()
pkg="package name"
activity="launcher activity"
max=32
count=0

trap "echo Interrupted; exit" INT

run() {
  adb shell am start -S -W $pkg/$activity -c android.intent.category.LAUNCHER -a android.intent.action.MAIN
}

while [ $count -lt $max ]; do
  t=$(run | grep 'TotalTime' | cut -d' ' -f2)
  if [ ! -z "$t" ]; then
    times+=($t)
    ((count++))
    echo "Run $count: $t ms"
  else
    echo "Oops, something went wrong."
    break
  fi
done

if [ ${#times[@]} -gt 0 ]; then
  total=0
  for i in "${times[@]}"; do
    ((total += i))
  done
  avg=$((total / ${#times[@]}))
  echo "Done! Avg time: ${avg} ms for ${#times[@]} starts"
else
  echo "No data collected."
fi
