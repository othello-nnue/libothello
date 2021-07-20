#!/bin/bash
cd /tmp
URL = $(wget -O - https://ziglang.org/download/index.json | jq -r '.master."x86_64-linux".tarball' 2>&1)
wget $URL
tar xf $(basename $url)
mv (basename -s .tar.xz $url)/ "$HOME"/zig
cd -
