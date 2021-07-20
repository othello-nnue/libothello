#!/bin/bash
cd /tmp
URL=$(wget -O - https://ziglang.org/download/index.json | jq -r '.master."'$(arch)'-linux".tarball' 2>&1)
wget $URL
tar xf $(basename $url)
mkdir "$ZIG_DIR"
mv $(basename -s .tar.xz $url)/ "$ZIG_DIR"
cd -
