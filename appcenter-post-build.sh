# Sample post-build script for Github PR checks
#
# This script updates the Github status for commits based on whether or not
# a successful build occurred against that sha. It can be used in conjunction
# with the Azure Function to create a end to end PR check workflow or alone if
# you only wish to check branches preconfigured for continuous builds in App Center.
SHA = git rev-parse HEAD 2> /dev/null | sed "s/\(.*\)/@\1/"
github_notify_build_passed() {
  curl -H "Content-Type: application/json" \
  -H "Authorization: token ${prbuild_GITHUB_TOKEN}" \
  -H "User-Agent: appcenter-ci" \
  -H "Content-Type: application/json" \
  --data "{
          \"state\": \"success\",
          \"target_url\": \"https://appcenter.ms/${prbuild_appcenter_owner_type}/${prbuild_appcenter_owner}/apps/${prbuild_appcenter_app}/build/branches/${APPCENTER_BRANCH}\",
          \"description\": \"App Center build successfully created.\",
          \"context\": \"continuous-integration/appcenter/${prbuild_appcenter_app}\"
        }" \
       https://api.github.com/repos/${prbuild_repo_owner}/${prbuild_repo_name}/statuses/${SHA##*@}
}

github_notify_build_failed() {
  curl -H "Content-Type: application/json" \
  -H "Authorization: token ${GITHUB_TOKEN}" \
  -H "User-Agent: appcenter-ci" \
  -H "Content-Type: application/json" \
  --data "{
          \"state\": \"failure\",
          \"target_url\": \"https://appcenter.ms/${prbuild_appcenter_owner_type}/${prbuild_appcenter_owner}/apps/${prbuild_appcenter_app}/build/branches/${APPCENTER_BRANCH}\",
          \"description\": \"Errors occurred during App Center build.\",
          \"context\": \"continuous-integration/appcenter/${prbuild_appcenter_app}\"
        }" \
        https://api.github.com/repos/${prbuild_repo_owner}/${prbuild_repo_name}/statuses/${SHA##*@}
}

if [ "$AGENT_JOBSTATUS" != "Succeeded" ]; then
    github_notify_build_failed
    exit 0
fi

github_notify_build_passed