#!/bin/bash

set -e

# Usage: ./evaluate.sh <projects_file>
# projects_file should contain lines in the format: owner/repo
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <projects_file>"
    exit 1
fi

PROJECTS_FILE=$1

if [ ! -f "$PROJECTS_FILE" ]; then
    echo "File not found: $PROJECTS_FILE"
    exit 1
fi

# Check if GITHUB_TOKEN is set.
if [ -z "$GITHUB_TOKEN" ]; then
    echo "GITHUB_TOKEN is not set. It is highly reccomended."
fi

echo -e "Project\tStars\tCommits\tReleases\tOpen PRs\tScorecard Score"

SCORECARD_CHECKS="Dangerous-Workflow,Code-Review,CII-Best-Practices,Security-Policy,SAST,Contributors,Signed-Releases,Packaging,Dependency-Update-Tool,CI-Tests,Token-Permissions,Fuzzing,License,Vulnerabilities,Binary-Artifacts,Maintained,Pinned-Dependencies"

while IFS= read -r project; do
    OWNER=$(echo $project | cut -d'/' -f1)
    REPO=$(echo $project | cut -d'/' -f2)

    # Get repository data
    REPO_DATA=$(curl -s -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/repos/$OWNER/$REPO)
    STARS=$(echo $REPO_DATA | jq .stargazers_count)
    COMMITS=$(curl -s -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/repos/$OWNER/$REPO/commits | jq length)
    RELEASES=$(curl -s -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/repos/$OWNER/$REPO/releases | jq length)
    OPEN_PRS=$(curl -s -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/repos/$OWNER/$REPO/pulls?state=open | jq length)


    # New API call to fetch license information
    LICENSE_DATA=$(curl -s -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/repos/$OWNER/$REPO/license")

    # Extract license name or key
    LICENSE=$(echo $LICENSE_DATA | jq -r .license.spdx_id)

    if [ "$LICENSE" == "null" ]; then
        LICENSE="No license"
    fi

    # Run scorecard
    SCORECARD_SCORE=$(scorecard --repo=https://github.com/$OWNER/$REPO --format=json --checks $SCORECARD_CHECKS | jq '.score')

    # Append each line of output to results.txt
    echo -e "$project\t$STARS\t$COMMITS\t$RELEASES\t$OPEN_PRS\t$SCORECARD_SCORE\t$LICENSE" >> results.txt
done < "$PROJECTS_FILE"

column -t -s $'\t' results.txt