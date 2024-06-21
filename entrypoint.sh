#!/usr/bin/env bash
#   ########################################################################
#   Copyright 2024 KhulnaSoft Ltd.
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
#   ######################################################################## 

SOURCE_REGEX='^.*/$'
if [[ $INPUT_SOURCE =~ $SOURCE_REGEX ]];
then
    echo Removing trailing / from INPUT_SOURCE slim is picky
    INPUT_SOURCE=$(echo $INPUT_SOURCE | sed 's/\(.*\)\//\1/')
fi
slim generate-manifest $INPUT_SOURCE --update >/tmp/app.manifest   || true
cp  /tmp/app.manifest  $INPUT_SOURCE/app.manifest
mkdir -p build/package/khulnasoftbase
mkdir -p build/package/deployment
slim package -o build/package/khulnasoftbase $INPUT_SOURCE 
mkdir -p build/package/deployment
for f in build/package/khulnasoftbase/*.tar.gz; do
  n=$(echo $f | awk '{gsub("-[0-9]+.[0-9]+.[0-9]+-[a-f0-9]+-?", "");print}' | sed 's/.tar.gz/.spl/')
  mv $f $n
done
PACKAGE=$(ls build/package/khulnasoftbase/*)

slim partition $PACKAGE -o build/package/deployment/ || true
for f in build/package/deployment/*.tar.gz; do
  n=$(echo $f | awk '{gsub("-[0-9]+.[0-9]+.[0-9]+-[a-f0-9]+-?", "");print}' | sed 's/.tar.gz/.spl/')
  mv $f $n
done
slim validate $PACKAGE

chmod -R +r build

echo "OUTPUT=$PACKAGE" >> $GITHUB_OUTPUT
