#!/bin/bash

echo "[DOCSCRIPT] Updating gh-pages branch..."
git checkout master
git branch -D gh-pages
git branch gh-pages
git checkout gh-pages

find . -not -path './Documentation/*' -not -path './Documentation' -not -path './.git/*' -not -path './.git' -delete

cp -R Documentation/html/* .

git add -A
git commit -m "[DOCSCRIPT] Deploying Documentation to gh-pages branch"

echo "[DOCSCRIPT] Publishing documentation"

git push origin gh-pages
git checkout -f master
