#!/bin/env bash
echo "Updating all git repositories in current directory (including subdirectories)"
find $PWD -name .git -print -execdir git pull \;
