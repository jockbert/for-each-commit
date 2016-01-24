# for-each-commit
Do something for each commit in a branch in a Git-repository. It is a Scala script that executes a command for each commit from current commit (HEAD) to a earlier stop-commit (or initial commit of repo, if not specifified).

Useful for extracting some metric for each and every commit in a branch, such as e.g. some performance meassurement for each commit of your master branch.

## Usage

     $ cd /my/git/repo
     $ scala path/to/for-each-commit.ss <command> [<stopCommit>]


## Example

     $ cd ~/myRepo
     $ scala ~/for-each-commit.ss 'echo hello world'

## Hint

Add **for-each-commit** as a alias to your ~/.bashrc

     alias for-each-commit="scala ~/<Some-Path>/for-each-commit.ss"
