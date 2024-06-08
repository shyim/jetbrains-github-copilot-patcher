#!/usr/bin/env bash

set -eo pipefail

latestNightly=$(curl -s "https://plugins.jetbrains.com/api/plugins/17718/updates?channel=nightly&page=1&size=8" | jq -r '. | first | .file')
latestDownload="https://downloads.marketplace.jetbrains.com/files/${latestNightly}"

curl -o copilot.zip -L "$latestDownload"

unzip -o copilot.zip -d copilot

rm -rf main-jar

fileName=""
found=0
for file in copilot/github-copilot-intellij/lib/*.jar; do
    if [[ $file == copilot/github-copilot-intellij/lib/github-copilot-intellij* ]]; then
        fileName="$file"
        found=1
        unzip -d main-jar "$file"
    fi
done

if [[ $found -eq 0 ]]; then
    echo "No jar file found"
    exit 1
fi

patchedXml=$(sed -r 's/until-build="[^"]*"?//' main-jar/META-INF/plugin.xml)

echo "$patchedXml" > main-jar/META-INF/plugin.xml

cd main-jar
zip -r ../patched-copilot.jar *
cd ..

mv patched-copilot.jar "$fileName"

cd copilot

zip -r ../patched-copilot.zip *

cd ..

rm -rf main-jar
rm -rf copilot
rm -rf copilot.zip