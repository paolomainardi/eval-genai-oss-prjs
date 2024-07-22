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

echo -e "Project\tStars\tCommits\tOpen PRs\tOpen Issues\tScorecard Score\tLanguage\tLicense" > results.txt

SCORECARD_CHECKS="Dangerous-Workflow,Code-Review,CII-Best-Practices,Security-Policy,SAST,Contributors,Signed-Releases,Packaging,Dependency-Update-Tool,CI-Tests,Token-Permissions,Fuzzing,License,Vulnerabilities,Binary-Artifacts,Maintained,Pinned-Dependencies"

while IFS= read -r project; do
    OWNER=$(echo $project | cut -d'/' -f1)
    REPO=$(echo $project | cut -d'/' -f2)

    echo "Evaluating $project"

    # Get repository data
    REPO_DATA=$(curl -s -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/repos/$OWNER/$REPO)
    STARS=$(echo $REPO_DATA | jq .stargazers_count)
    DEFAULT_BRANCH=$(echo $REPO_DATA | jq -r .default_branch)
    COMMITS=$(curl -s -H "Authorization: token $GITHUB_TOKEN" --head https://api.github.com/repos/$OWNER/$REPO/commits\?sha\=${DEFAULT_BRANCH}\&per_page\=1\&page\=1 | grep -i "Link:" | grep -o '<[^>]*>; rel="last"' | sed 's/.*<\(.*\)>.*/\1/' | sed 's/.*page=\([0-9]*\).*/\1/')
    OPEN_PRS=$(curl -s -H "Authorization: token $GITHUB_TOKEN" --head https://api.github.com/repos/$OWNER/$REPO/pulls?state=open\&per_page\=1\&page\=1 | grep -i "Link:" | grep -o '<[^>]*>; rel="last"' | sed 's/.*<\(.*\)>.*/\1/' | sed 's/.*page=\([0-9]*\).*/\1/')
    OPEN_ISSUES=$(echo $REPO_DATA | jq .open_issues)

    # New API call to fetch license information
    LICENSE_DATA=$(curl -s -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/repos/$OWNER/$REPO/license")

    # Extract license name or key
    LICENSE=$(echo $LICENSE_DATA | jq -r .license.spdx_id)

    if [ "$LICENSE" == "null" ]; then
        LICENSE="No license"
    fi

    # Fetch languages data
    LANGUAGES_DATA=$(curl -s -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/repos/$OWNER/$REPO/languages")

    # Parse and join languages
    LANGUAGES=$(echo $LANGUAGES_DATA | jq -r 'keys | join(",")')
    MAIN_LANGUAGE=$(echo $LANGUAGES_DATA | jq 'to_entries | .[0].key')

    # Check if no languages are found
    if [ -z "$LANGUAGES" ]; then
        LANGUAGES="No languages found"
    fi

    # Run scorecard
    SCORECARD_SCORE=$(scorecard --repo=https://github.com/$OWNER/$REPO --format=json --checks $SCORECARD_CHECKS | jq '.score')

    # Append each line of output to results.txt
    echo -e "$project\t$STARS\t$COMMITS\t$OPEN_PRS\t$OPEN_ISSUES\t$SCORECARD_SCORE\t$MAIN_LANGUAGE\t$LICENSE" >> results.txt
done < "$PROJECTS_FILE"

column -t -s $'\t' results.txt
