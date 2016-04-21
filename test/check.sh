#!/bin/bash

set -e

source $(dirname $0)/helpers.sh

it_can_list_branches_on_first_check() {
  local repo=$(init_repo)

  check_uri_first_time $repo | jq -e ". == [{\"increment\": \"1\", \"branches\": \"bogus master\"}]"
}

it_can_filter_based_on_branch_regexp() {
  local repo=$(init_repo)
  make_commit_to_branch $repo 'feature-1'

  check_uri_with_branch_regexp $repo | jq -e ". == [{\"increment\": \"2\", \"branches\": \"feature-1\"}]"
}

it_raises_error_if_more_than_max_branches() {
  local repo=$(init_repo)

max_branches_rc=1
$(check_uri_with_max_branches $repo) || max_branches_rc=$?
  if [ $max_branches_rc -ne 99 ]; then
    echo 'expected to exit with error code 99!'
    exit 1
  fi
}

it_returns_a_new_version_if_a_new_branch_was_added() {
  local repo=$(init_repo)
  make_commit_to_branch $repo 'feature-1'

  check_uri $repo | jq -e ". == [{\"increment\": \"2\", \"branches\": \"bogus feature-1 master\"}]"
}

it_returns_a_new_version_if_an_existing_branch_was_deleted() {
  local repo=$(init_repo)
  cd $repo
  git branch -D 'bogus'

  check_uri $repo | jq -e ". == [{\"increment\": \"2\", \"branches\": \"master\"}]"
}

it_does_not_return_a_new_version_if_no_new_or_deleted_branches() {
  local repo=$(init_repo)

  check_uri $repo | jq -e ". == []"
}

it_fails_if_key_has_password() {
  local repo=$(init_repo)
  make_commit $repo

  local key=$TMPDIR/key-with-passphrase
  ssh-keygen -f $key -N some-passphrase

  local failed_output=$TMPDIR/failed-output
  if check_uri_with_key $repo $key 2>$failed_output; then
    echo "checking should have failed"
    return 1
  fi

  grep "Private keys with passphrases are not supported." $failed_output
}

it_can_check_when_not_ff() {
  local repo=$(init_repo)
  local other_repo=$(init_repo)

  make_commit_to_branch $repo 'feature-1'

  make_commit $other_repo

  check_uri $other_repo

  cd "$TMPDIR/git-resource-repo-cache"

  # do this so we get into a situation that git can't resolve by rebasing
  git config branch.autosetuprebase never

  # set my remote to be the other git repo
  git remote remove origin
  git remote add origin $repo/.git

  # fetch so we have master available to track
  git fetch

  # setup tracking for my branch
  git branch -u origin/master HEAD

  check_uri $repo | jq -e ". == [{\"increment\": \"2\", \"branches\": \"bogus feature-1 master\"}]"
}

run it_can_list_branches_on_first_check
run it_can_filter_based_on_branch_regexp
run it_raises_error_if_more_than_max_branches
run it_returns_a_new_version_if_a_new_branch_was_added
run it_returns_a_new_version_if_an_existing_branch_was_deleted
run it_does_not_return_a_new_version_if_no_new_or_deleted_branches
run it_fails_if_key_has_password
run it_can_check_when_not_ff
