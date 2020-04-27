#!/bin/bash
cd "$(dirname "$0")"

splitRegex="([a-zA-Z0-9_\.-]+):([a-zA-Z0-9_\.-]+)~([a-zA-Z0-9_\.-]+)";

for project in "$@"; do
    if [[ $project =~ $splitRegex ]]; then
        repository=${BASH_REMATCH[1]};
        branchName=${BASH_REMATCH[2]};
        projectName=${BASH_REMATCH[3]};
    else
        printf "error: Unable to parse project description; Please provide projects in the form: '<repositoryName>:<branchName>~<projectName>'.\n\n";
        continue;
    fi

    if ! [ -d "./Masters/$repository" ]; then
        printf "error: Unable to locate repository '$repository'. Expected folder 'Masters/$repository' to exist.\n\n";
        continue;
    fi

    printf "Creating project-worktree based on '$repository/$branchName'...\n";
    cwd=$(pwd);
    cd "./Masters/$repository";

    remoteBranch=$(git for-each-ref --format='%(upstream:short)' "$(git rev-parse --symbolic-full-name $branchName)");
    if [ $? -ne 0 ]; then
        printf "error: Couldn't find matching local branch with name '$branchName' in repository '$repository'...\n\n";
    else
        git worktree add -b "$projectName" "../../Projects/$projectName" "$remoteBranch";
        printf "done.\n\n";
    fi

    cd "$cwd";
done
