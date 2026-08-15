#!/bin/zsh
SECTIONS=(bridge contact csl extend int_essay mentor now path recording review works)
for s in $SECTIONS; do
  cp doc/docinfo.html $s/doc/
  cp doc/docinfo-footer.html $s/doc/
done
