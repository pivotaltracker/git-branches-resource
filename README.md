# Git Branches Resource

Tracks when branches (refs) are added or removed from a [git](http://git-scm.com/) repository,
and returns a list of all current branches whenever any are added or removed.

Used by [Concourse Branch Manager](https://github.com/pivotaltracker/concourse-branch-manager)

## Source Configuration

* `uri`: *Required.* The location of the repository.

* `private_key`: *Optional.* Private key to use when pulling/pushing.
    Example:
    ```
    private_key: |
      -----BEGIN RSA PRIVATE KEY-----
      MIIEowIBAAKCAQEAtCS10/f7W7lkQaSgD/mVeaSOvSF9ql4hf/zfMwfVGgHWjj+W
      <Lots more text>
      DWiJL+OFeg9kawcUL6hQ8JeXPhlImG6RTUffma9+iGQyyBMCGd1l
      -----END RSA PRIVATE KEY-----
    ```

* `branch_regexp`: *Optional.*  A regular expression selecting the branches you wish to track.
  By default, all branches (i.e. `.*`) are selected.

* `max_branches`: *Optional, default is 20.*  The maximum number of branches to track.  If
  more than this number are selected by `branch_regexp`, an error will be returned.

### Example

Resource configuration for a private repo:

``` yaml
resources:
- name: git-branches
  type: git-branches
  branch_regexp: ".*" # This is the default
  max_branches: 20 # This is the default
  source:
    uri: git@github.com:concourse/git-resource.git
    private_key: |
      -----BEGIN RSA PRIVATE KEY-----
      MIIEowIBAAKCAQEAtCS10/f7W7lkQaSgD/mVeaSOvSF9ql4hf/zfMwfVGgHWjj+W
      <Lots more text>
      DWiJL+OFeg9kawcUL6hQ8JeXPhlImG6RTUffma9+iGQyyBMCGd1l
      -----END RSA PRIVATE KEY-----
```

## Behavior

### `check`: Check for added or deleted branches since last run.

The repository is cloned (or pulled if already present), if any branches
were added or deleted, or if no version is given, a single version
containing the repo uri and an array of all branches matching the
`branch_regex`, up to `max_branches`, is returned.

### `in`: Clone the repository, at the given ref.

Writes the a hash containing the uri and the selected array of branches to
`git-branches.json` in the destination directory.

### `out`: Push to a repository.

Not implemented.

## Runnings tests locally

* Symlink `assets` dir to `/opt/resource`,
  e.g.: `sudo ln -s /path/to/git-branches-resource/assets /opt/resource`
* Change ownership of dir to local user, e.g. `sudo chown myuser /opt/resource`  
* `test/all.sh`
* Manually comment/uncomment test invocations at bottom of individual test
  files to run "focused" tests

## Release Process Notes


* Docker Repo Page: https://hub.docker.com/r/tracker/git-branches-resource/

### Publishing

* Make a git tag and push
* Auth to docker: `docker login`
* Make a docker tag (where "N" matches tag `0.N.0`: `docker tag tracker/git-branches-resource tracker/git-branches-resource:N`
* Push to docker "N" tag: `docker push tracker/git-branches-resource:N`
* Push to docker "latest" tag: `docker push tracker/git-branches-resource`
