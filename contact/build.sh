#!/bin/zsh
pwd
asciidoctor -D . doc/index.adoc
rsync -a --verbose --perms --times  --prune-empty-dirs --delete-after doc/images .
#rsync -a --verbose --perms --times  --prune-empty-dirs --delete-after doc/pdf .
#$NUAGE/software/tools/linkcheck -e --no-show-redirects localhost:8080/index.html
