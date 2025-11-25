#!/bin/bash

# GitHub Workflow Management Script
# This script helps trigger and monitor GitHub Actions workflows

# Set your GitHub token as an environment variable:
# export GITHUB_TOKEN="your_token_here"

if [ -z "$GITHUB_TOKEN" ]; then
    echo "Error: GITHUB_TOKEN environment variable not set"
    echo "Please set it with: export GITHUB_TOKEN='your_token_here'"
    exit 1
fi

REPO="superpeiss/ios-app-fa526759-42c6-474a-a1e5-be9f23b40e39"
API_BASE="https://api.github.com/repos/$REPO"

function trigger_workflow() {
    echo "🚀 Triggering iOS Build workflow..."

    curl -k -X POST \
      "$API_BASE/actions/workflows/ios-build.yml/dispatches" \
      -H "Authorization: token $GITHUB_TOKEN" \
      -H "Accept: application/vnd.github.v3+json" \
      -H "Content-Type: application/json" \
      -d '{"ref":"main"}' 2>&1

    echo "✅ Workflow triggered! Check status with: $0 status"
}

function get_status() {
    echo "📊 Fetching workflow run status..."

    curl -k -H "Authorization: token $GITHUB_TOKEN" \
      -H "Accept: application/vnd.github.v3+json" \
      "$API_BASE/actions/runs" 2>&1 | \
      grep -E '"id"|"run_number"|"status"|"conclusion"' | \
      head -20
}

function get_latest_run() {
    echo "🔍 Getting latest workflow run details..."

    curl -k -H "Authorization: token $GITHUB_TOKEN" \
      -H "Accept: application/vnd.github.v3+json" \
      "$API_BASE/actions/runs" 2>&1 | \
      grep -A 10 '"workflow_runs"' | head -25
}

function download_logs() {
    RUN_ID="$1"

    if [ -z "$RUN_ID" ]; then
        echo "Usage: $0 download <run_id>"
        exit 1
    fi

    echo "📥 Downloading logs for run $RUN_ID..."

    # Get artifact URL
    ARTIFACT_URL=$(curl -k -H "Authorization: token $GITHUB_TOKEN" \
      -H "Accept: application/vnd.github.v3+json" \
      "$API_BASE/actions/runs/$RUN_ID/artifacts" 2>&1 | \
      grep -o '"archive_download_url":"[^"]*' | \
      grep -o 'https://[^"]*' | head -1)

    if [ -n "$ARTIFACT_URL" ]; then
        echo "Found artifact: $ARTIFACT_URL"
        curl -k -L -H "Authorization: token $GITHUB_TOKEN" \
          "$ARTIFACT_URL" -o "build-log-$RUN_ID.zip"
        echo "✅ Downloaded to build-log-$RUN_ID.zip"
    else
        echo "❌ No artifacts found for run $RUN_ID"
    fi
}

function help() {
    echo "GitHub Workflow Management Script"
    echo ""
    echo "Usage:"
    echo "  $0 trigger       - Trigger a new workflow run"
    echo "  $0 status        - Get status of recent runs"
    echo "  $0 latest        - Get detailed info on latest run"
    echo "  $0 download <id> - Download build logs for a run"
    echo "  $0 help          - Show this help message"
    echo ""
    echo "Web Interface:"
    echo "  Repository: https://github.com/$REPO"
    echo "  Actions:    https://github.com/$REPO/actions"
}

# Main script logic
case "$1" in
    trigger)
        trigger_workflow
        ;;
    status)
        get_status
        ;;
    latest)
        get_latest_run
        ;;
    download)
        download_logs "$2"
        ;;
    help|--help|-h|"")
        help
        ;;
    *)
        echo "Unknown command: $1"
        help
        exit 1
        ;;
esac
