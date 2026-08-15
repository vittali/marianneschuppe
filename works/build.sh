#!/bin/zsh
pwd
asciidoctor -D . doc/index.adoc
asciidoctor -D . doc/composer-performer.adoc
asciidoctor -D . doc/composing-for-voices.adoc
asciidoctor -D . doc/collective-and-interdisciplinary-work.adoc
asciidoctor -D . doc/passing-through-words.adoc
asciidoctor -D . doc/extending.adoc
rsync -a --verbose --perms --times  --prune-empty-dirs --delete-after doc/images .
rsync -a --verbose --perms --times  --prune-empty-dirs --delete-after doc/pdf .
# The extending and passing-through-words pages include content from the legacy
# section sources, so copy their referenced assets into the /works paths too.
rsync -a --verbose --perms --times ../extend/images/ images/
rsync -a --verbose --perms --times ../extend/pdf/ pdf/
rsync -a --verbose --perms --times ../bridge/pdf/ pdf/
#$NUAGE/software/tools/linkcheck -e --no-show-redirects localhost:8080/index.html
