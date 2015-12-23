#!/bin/sh

set -e -u

set -o pipefail

resource_dir=/opt/resource

run() {
  export TMPDIR=$(mktemp -d ${TMPDIR_ROOT}/git-tests.XXXXXX)

  echo -e 'running \e[33m'"$@"$'\e[0m...'
  eval "$@" 2>&1 | sed -e 's/^/  /g'
  echo ""
}

init_repo() {
  (
    set -e

    cd $(mktemp -d $TMPDIR/repo.XXXXXX)

    git init -q

    # start with an initial commit
    git \
      -c user.name='test' \
      -c user.email='test@example.com' \
      commit -q --allow-empty -m "init"

    # create some bogus branch
    git checkout -b bogus

    git \
      -c user.name='test' \
      -c user.email='test@example.com' \
      commit -q --allow-empty -m "commit on other branch"

    # back to master
    git checkout master

    # print resulting repo
    pwd
  )
}

make_commit_to_file_on_branch() {
  local repo=$1
  local file=$2
  local branch=$3
  local msg=${4-}

  # ensure branch exists
  if ! git -C $repo rev-parse --verify $branch > /dev/null 2>&1; then
    git -C $repo branch $branch master
  fi

  # switch to branch
  git -C $repo checkout -q $branch

  # modify file and commit
  echo x >> $repo/$file
  git -C $repo add $file
  git -C $repo \
    -c user.name='test' \
    -c user.email='test@example.com' \
    commit -q -m "commit $(wc -l $repo/$file) $msg"
}

make_commit_to_file() {
  make_commit_to_file_on_branch $1 $2 master "${3-}"
}

make_commit_to_branch() {
  make_commit_to_file_on_branch $1 some-file $2
}

make_commit() {
  make_commit_to_file $1 some-file
}

check_uri() {
  jq -n "{
    source: {
      uri: $(echo $1 | jq -R .)
    },
    version: {increment: \"1\", branches: \"bogus master\"}
  }" | ${resource_dir}/check | tee /dev/stderr
}

check_uri_with_branch_regexp() {
  jq -n "{
    source: {
      uri: $(echo $1 | jq -R .),
      branch_regexp: \"feature\"
    },
    version: {increment: \"1\", branches: \"bogus master\"}
  }" | ${resource_dir}/check | tee /dev/stderr
}

check_uri_with_max_branches() {
  jq -n "{
    source: {
      uri: $(echo $1 | jq -R .),
      max_branches: 1
    },
    version: {increment: \"1\", branches: \"bogus master\"}
  }" | ${resource_dir}/check | tee /dev/stderr
}

check_uri_first_time() {
  jq -n "{
    source: {
      uri: $(echo $1 | jq -R .)
    },
    version: null
  }" | ${resource_dir}/check | tee /dev/stderr
}


check_uri_with_key() {
  jq -n "{
    source: {
      private_key: $(cat $2 | jq -s -R .)
    }
  }" | ${resource_dir}/check | tee /dev/stderr
}


get_version() {
  jq -n "{
    source: {
      uri: $(echo $1 | jq -R .)
    },
    version: {
      increment: \"1\",
      branches: \"bogus master\"
    }
  }" | ${resource_dir}/in "$2" | tee /dev/stderr
}
