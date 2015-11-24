#!/bin/sh

set -e

source $(dirname $0)/helpers.sh

it_can_get() {
  local repo=$(init_repo)
  local dest=$TMPDIR/destination

  get_version $repo $dest | jq -e "
    . == {uri: $(echo $repo | jq -R .)
    , \"branches\": [\"bogus\",\"master\"]}
  "

  test -e $dest/version.json
  cat $dest/version.json | jq -e ". == {uri: $(echo $repo | jq -R .)
    ,\"branches\": [\"bogus\",\"master\"]}"
}

run it_can_get
