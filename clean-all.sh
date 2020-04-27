#!/bin/bash
cd "$(dirname "$0")"

nameRegex="/([^/ ]+)\.git$";

read -p "Are you sure? (y/n)" prompt;
if ! [ "$prompt" == "y" ]; then
    exit;
fi

printf "Cleaning Masters...\n";
while read line; do
    if ! [ -z "$line" ]; then
        if [[ $line =~ $nameRegex ]]; then
            name=${BASH_REMATCH[1]};
        else
            printf "error: Malformed repository descriptor: '$line'. Skipping...\n";
            continue;
        fi

        if [ -d "./Masters/$name" ]; then
            printf "    Deleting 'Masters/$name'\n";
            rm -r "./Masters/$name";
        fi
    fi
done < "./repo-list"
printf "done.\n\n";

printf "Cleaning Builds...\n";
shopt -s nullglob
for filename in ./Builds/*; do
    printf "    Deleting '$filename'\n";
    rm -r "$filename";
done
shopt -u nullglob
printf "done.\n\n";
