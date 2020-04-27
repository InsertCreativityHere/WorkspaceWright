#!/bin/bash
cd "$(dirname "$0")"

shopt -s nullglob
nameRegex="/([^/ ]+)\.git$";

printf "Cloning repositories...\n\n";
while read line; do
    if ! [ -z "$line" ]; then
        if [[ $line =~ $nameRegex ]]; then
            name=${BASE_REMATCH[1]};
        else
            printf "error: Malformed repository descriptor: '$line'. Skipping...\n\n";
            continue;
        fi

        if [ -d "./Masters/$name" ]; then
            printf "'$name' already exists, skipping...\n\n";
            continue;
        fi

        remoteRegex="/([^/ ]+)/$name";
        if [[ $line =~ $remoteRegex ]]; then
            remoteRepo=${BASE_REMATCH[1]};
        else
            printf "error: Malformed repository descriptor: '$line'. Skipping.\n\n";
            continue;
        fi

        printf "cloning '$line...\n";
        cwd=$(pwd);
        cd "./Masters";
        git clone "$line";

        if [ $? -ne 0 ]; then
            printf "error: Failed to clone '$line'.\n\n";
            continue;
        fi

        if ! [ -d "$name" ]; then
            printf "error: No repository found for '$name' after cloning.\n\n";
            continue;
        fi

        cd "./$name";
        git remote rename origin "$remoteRepo";

        cd "$cwd";
        printf "done.\n\n";
    fi
done < "./repo-list"

bash "./update-all.sh";

if [ -d "config" ]; then
    printf "Building workspace and configuring repositories...\n\n";
    while read line; do
        if ! [ -z "$line" ]; then
            if [[ $line =~ $nameRegex ]]; then
                name=${BASE_REMATCH[1]};
            else
                printf "error: Malformed repository descriptor: '$line'. Skipping...\n\n";
                continue;
            fi

            if ! [ -d "./Masters/$name" ]; then
                printf "error: No repository found for '$name'.\n\n";
                continue;
            fi

            echo "Configuring '$name'...\n";
            cwd=$(pwd);
            cd "./Masters/$name"

            if [ -f "../../config/global" ]; then
                source "../../config/global";
            fi

            if [ -f "../../config/$name" ]; then
                source "../../config/$name";
            fi

            printf "done.\n\n";
            cd "cwd";
        fi
    done < "./repo-list"

    printf "Running post-configuration updates...\n\n";
    bash "./update-all.sh";
fi
