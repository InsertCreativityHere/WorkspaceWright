#!/bin/bash
cd "$(dirname "$0")"

printf "Initializing workspace structure...\n";
mkdir -pv "Builds" "Masters" "Projects";
if [ $? -ne 0 ]; then
    printf "error: Failed to create workspace folders... Aborting.\n\n";
    exit 1;
fi

bash "./clone-all.sh";
printf 'Finished!\n\n';
