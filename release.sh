#!/bin/bash
npm run release;
cd ./release;
git archive --format zip HEAD > ../releases/new_release.zip;
cd ..;