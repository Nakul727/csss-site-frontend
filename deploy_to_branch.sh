#!/bin/bash

echo "Installing packages..."
npm ci

echo "Building frontend..."
npm run build

echo "Checking out the build branch..."

# store current branch (e.g., "main") in current_branch
current_branch=$(git branch --show-current)

git checkout build

# don't proceed if the branch wasn't changed
branch=$(git branch --show-current)
if [ $branch != "build" ]; then
	exit 1
fi

# pull, copy, add build files to the root of the build branch
git pull origin build
cp -R build/* .
git add .

# wait for user input before proceeding
while true; do
	git status
	echo "(P)roceed, (m)anual, (c)ancel?"
	read choice

	if [ $choice = "P" ]; then
		break
	elif [ $choice = "m" ]; then
		echo "Happy hacking!"
		exit 0
	elif [ $choice = "c" ]; then
		echo "Cancelling..."
		git restore --staged .
		git restore .
		git checkout $working_branch
		exit 0
	else
		echo "Not sure what you mean..."
	fi
done

git commit -m "Updates"
git push origin build
git checkout $current_branch

echo "Finished!"
