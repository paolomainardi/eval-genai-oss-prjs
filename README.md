# GitHub Repository Analyzer

## Overview

The GitHub Repository Analyzer is a shell script designed to fetch and analyze data from GitHub repositories. It gathers information such as star count, number of commits, open pull requests, open issues, programming languages used, the main programming language, and license information. This data is then compiled into a tabulated format for easy analysis.

## Features

- **Star Count**: Retrieves the total number of stars for each repository.
- **Commit Count**: Counts the total number of commits made in the repository.
- **Open Pull Requests**: Lists the number of open pull requests.
- **Open Issues**: Lists the number of open issues.
- **Programming Languages**: Identifies all programming languages used in the repository.
- **Main Programming Language**: Highlights the primary programming language of the repository.
- **License Information**: Provides the type of license the repository is under.
- **Scorecard Analysis**: Utilizes Scorecard to analyze the repository for specific checks and returns a score.

## Prerequisites

Before running this script, ensure you have the following installed:
- `jq`: A lightweight and flexible command-line JSON processor.
- `curl`: A tool to transfer data from or to a server.
- `scorecard`: A security tool to analyze the security posture of your project.

Additionally, you will need a GitHub Personal Access Token with appropriate permissions set as an environment variable:
```bash
export GITHUB_TOKEN='your_github_token_here'

## Usage

1. Prepare a List of Repositories: Create a text file named projects.txt and list the GitHub repositories you want to analyze, one per line in the format owner/repo.

2. Run the Script: Execute the script in your terminal:

3. View Results: The script outputs the results into results.txt and formats it for console viewing. You can open results.txt for a detailed report.