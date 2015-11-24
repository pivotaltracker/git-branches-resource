# Git Branches Resource

Tracks when branches (refs) are added or removed from a [git](http://git-scm.com/) repository,
and returns a list of all current branches whenever any are added or removed.

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

### Example

Resource configuration for a private repo:

``` yaml
resources:
- name: git-branches
  type: git-branches
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
containing the repo uri and an array of all branches is returned.

### `in`: Clone the repository, at the given ref.

Writes the version (containing uri and array of branches) to
`version.json` in the destination directory.

### `out`: Push to a repository.

Not implemented.
