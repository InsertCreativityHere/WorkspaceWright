#!/bin/bash
cd "$(dirname "$0")"

nameRegex="/([^/ ]+)\.git$";

printf "Updating Masters...\n\n";
while read line; do
    if ! [ -z "$line" ]; then
        if [[ $line =~ $nameRegex ]]; then
            name=${BASH_REMATCH[1]};
        else
            printf "error: Malformed repository descriptor: '$line'. Skipping...\n\n";
            continue;
        fi

        if ! [ -d "Masters/$name" ]; then
            printf "error: No repository found for '$name', skipping...\n\n";
            continue;
        fi

        remoteRegex="/([^/ ]+)/$name";
        if [[ $line =~ $remoteRegex ]]; then
            remoteRepo=${BASH_REMATCH[1]};
        else
            printf "error: Malformed repository descriptor: '$line'. Skipping...\n\n";
            continue;
        fi

        printf "Updating branches for '$name'...\n";
        cwd=$(pwd);
        cd "./Masters/$name";
        git fetch "$remoteRepo"
        currentBranch=$(git rev-parse --abbrev-ref HEAD);

        for remoteBranch in `git branch -r | grep -v HEAD`; do
            remoteBranch=$(echo "$remoteBranch" | tr -d '[:space:]');
            branch="${remoteBranch#$remoteRepo/}";

            if ! [[ $(git branch --list "$branch") ]]; then
                printf "Checking out local copy of new remote branch '$branch'.\n";
                git branch --track "$branch" "$remoteBranch";
            fi

            rrb="refs/remotes/$remoteRepo/$branch";
            rlb="refs/heads/$branch";

            behindCount=$(( $(git rev-list --count $rlb..$rrb 2>/dev/null) +0));
            aheadCount=$(( $(git rev-list --count $rrb..$rlb 2>/dev/null) +0));

            if [ "$behindCount" -gt 0 ]; then
                if [ "$aheadCount" -gt 0 ]; then
                    echo "$branch is $behindCount commit(s) behind and $aheadCount commit(s) ahead of '$remoteBranch' and could not be fast-forwarded";
                elif [ "$branch" == "$currentBranch" ]; then
                    git merge -q --ff-only $rrb;
                else
                    git fetch "$remoteRepo" "$branch":"$branch";
                fi
            fi
        done

        cd "$cwd";
        printf "done.\n\n";
    fi
done < "./repo-list"

printf "Updating Builds...\n\n";
shopt -s nullglob
for build in ./Builds/*; do
    cwd=$(pwd);
    cd "$build";
    currentBranch=$(git for-each-ref --format='%(upstream:short)' "$(git symbolic-ref -q HEAD)");
    if [ -z "$currentBranch" ]; then
        printf "Folder '$build' isn't linked to any build branch. Skipping...\n\n";
    fi

    printf "Updating '$currentBranch' in '$build'...\n";
    git merge --ff-only "$currentBranch";
    cd "$cwd";
    printf "done.\n\n";
done
shopt -u nullglob
