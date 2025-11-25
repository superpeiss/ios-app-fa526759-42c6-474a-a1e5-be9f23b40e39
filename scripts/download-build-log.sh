#!/bin/bash

# Script to download and view GitHub Actions build logs

GITHUB_TOKEN="$1"
RUN_ID="$2"

if [ -z "$GITHUB_TOKEN" ] || [ -z "$RUN_ID" ]; then
    echo "Usage: $0 <github_token> <run_id>"
    exit 1
fi

REPO="superpeiss/ios-app-fa526759-42c6-474a-a1e5-be9f23b40e39"

# Get artifacts
curl -k -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/$REPO/actions/runs/$RUN_ID/artifacts" \
  > /tmp/artifacts.json

# Extract artifact URL
ARTIFACT_URL=$(grep -o '"archive_download_url":"[^"]*' /tmp/artifacts.json | grep -o 'https://[^"]*' | head -1)

if [ -n "$ARTIFACT_URL" ]; then
    echo "Downloading build log from: $ARTIFACT_URL"
    curl -k -L -H "Authorization: token $GITHUB_TOKEN" \
      -H "Accept: application/vnd.github.v3+json" \
      "$ARTIFACT_URL" -o /tmp/build-log.zip
    echo "Downloaded to /tmp/build-log.zip"
fi
