# Sample post-build script for Github PR checks
#
# This script updates the Github status for commits based on whether or not
# a successful build occurred against that sha. It can be used in conjunction
# with the Azure Function to create a end to end PR check workflow or alone if
# you only wish to check branches preconfigured for continuous builds in App Center.

github_notify_build_passed() {
  curl -H "Content-Type: application/json" \
  -H "Authorization: token ${GITHUB_TOKEN}" \
  -H "User-Agent: appcenter-ci" \
  -H "Content-Type: application/json" \
  --data '{
          "state": "success",
          "target_url": "https://appcenter.ms/${appcenter_owner_type}/${appcenter_owner}/apps/${appcenter_app}/build/branches/${branch_template}",
          "description": "App Center build successfully created.",
          "context": "continuous-integration/appcenter"
        }' \
       https://api.github.com/repos/{$repo_owner}/{$repo_name}/statuses/${sha}
}

github_notify_build_failed() {
  curl -H "Content-Type: application/json" \
  -H "Authorization: token ${GITHUB_TOKEN}" \
  -H "User-Agent: appcenter-ci" \
  -H "Content-Type: application/json" \
  --data '{
          "state": "failure",
          "target_url": "https://appcenter.ms/${appcenter_owner_type}/${appcenter_owner}/apps/${appcenter_app}/build/branches/${branch_template}",
          "description": "Errors occurred during App Center build.",
          "context": "continuous-integration/appcenter"
        }' \
        https://api.github.com/repos/${repo_owner}/${repo_name}/statuses/${sha}
}

if [ "$AGENT_JOBSTATUS" != "Succeeded" ]; then
    github_notify_build_failed
    exit 0
fi

env 

github_notify_build_passed
