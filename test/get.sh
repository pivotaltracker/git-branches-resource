#!/bin/sh

set -e

source $(dirname $0)/helpers.sh

it_can_get() {
  local repo=$(init_repo)
  local dest=$TMPDIR/destination

  get_version $repo $dest | jq -e ". == {\"increment\": \"1\", \"branches\": [\"bogus\",\"master\"]}"

  test -e $dest/git-branches.json
  cat $dest/git-branches.json | jq -e ". ==
    {
      uri: $(echo $repo | jq -R .),
     \"branches\": [\"bogus\",\"master\"]
     }"
}

run it_can_get
