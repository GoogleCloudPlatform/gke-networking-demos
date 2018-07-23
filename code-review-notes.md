# Code review notes

Note: Please remove me.  Do not merge into master

1. rename all bash scripts to have the extension '.sh'
2. not certain why we have leading spacing
3. need to remove the .DS_Store dirs.  I merged a gitignore file
4. nginx dir ... how about rename that to manifests?

Cleanup.sh

#
# Code review notes
# - remove leading spaces on every line
# - i think comments would read eaiser with a space between the '#' and the first character of the comment
# - you need to check for gcloud and kubectl commands, help me share my scripts with you and 
#  I can show your how to do it in bash
# - you need to check that $1 and $2 are set correctly on the command line
# - please set your file path correctly, again I have some example code
# - explain why you are sleeping before you delete the cluster
#

install.sh
# Code Review Notes
# - see cleanup notes.  They apply here as well.
# - keep lines around 80 chars.  Especially with comments.



