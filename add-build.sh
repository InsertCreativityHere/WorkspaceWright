#!/bin/bash
cd "$(dirname "$0")"

splitRegex="([a-zA-Z0-9_\\-\\.]+):([a-zA-Z0-9_i\\-\\.]+)";

for branch in "$@"; do
    if [[ $branch =~ $splitRegex ]]; then
        repository=${BASH_REMATCH[1]};
        branchName=${BASH_REMATCH[2]};
    else
        printf "error: Unable to parse branch description; Please provide branches in the form: '<repositoryName>:<branchName>'.\n\n";
        continue;
    fi

    if ! [ -d "./Masters/$repository" ]; then
        printf "error: Unable to locate repository '$repository'. Expected folder 'Masters/$repository' to exist.\n\n";
        continue;
    fi

    printf "Creating build-worktree for '$branch'...\n";
    cwd=$(pwd);
    cd "./Masters/$repository";

    remoteBranch=$(git for-each-ref --format='%(upstream:short)' "$(git rev-parse --symbolic-full-name $branchName)");
    if [ $? -ne 0 ]; then
        printf "error: Couldn't find matching local branch with name '$branchName' in repository '$repository'...\n\n";
    else
        git worktree add --track -b "$branchName-build" "../../Builds/$repository-$branchName" "$remoteBranch";
        printf "done.\n\n";
    fi

    cd "$cwd";
done
