## Upload to GitHub

The script in this directory is designed to support the use of GitHub Code Scanning to display CodeQL results for repositories not hosted on a GitHub instance.

It does this by performing a lightweight "mirroring" after CodeQL analysis has completed. The source archive of the CodeQL database (containing every file analyzed during the build) is synced

### Usage

> **This script can only be used on CodeQL databases created on Linux**

```sh
upload-to-github.sh <repository_url> <local_clone_dir> <branch> <original_revision_id> <codeql_database_dir>
```

 * `<repository_url>` - the URL of a repository on GitHub. This repository must exist, although it does not need to contain any files. `git clone` and other remote commands on this repository should succeed without requiring any interactive prompt.
  * `<local_clone_dir>` - the directory into which to clone the repository. If this directory already exists, and contains an appropriate git repository, it will not be re-cloned.
  * `<branch>` - the branch on which to make the mirrored commit. A separate branch name should be used for each branch equivalent in the original version control system. In order to achieve the best experience, uploads to a branch should applied in an order consistent with the original version control system.
  * `<original_revision_id>` - a string describing the revision or version being analyzed in the original version control system. This will be used as part of the commit message so that results can easily be traced back to the original change.
  * `<codeql_database_dir>` - the directory containing the fully finalized CodeQL database created for this revision or version. This script can either be run before or after `codeql database analyze`.


Once the script has completed, you can upload the results using:

```
codeql github upload-results --repository <repository_url> --ref refs/heads/<branch> --commit `git rev-parse HEAD <local_clone_dir>` ....
```

### Note on consistency

It is important that uploads to a given branch are from the same "branch equivalent" in the original version control system, and are ordered in the same sequence. In other words, do not upload results for an "older" or "different" version than previously uploaded to that branch.

If these rules are followed, then the GitHub Code Scanning interface will properly track the currently open issues, and identify in which analyzed commit the issue was first closed. Uploading old analysis data may lead to newer issues being closed in the Code Scanning interface, even though they may still be present in the codebase.

GitHub Code Scanning defaults to showing results for the "main" branch on the git repository. We therefore recommend pushing your main-equivalent to the "main" branch. Results for other branches can be viewed by using the "Branch" filter drop-down in the user interface.