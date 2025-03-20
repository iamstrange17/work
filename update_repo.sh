#!/bin/bash

# Check if two parameters are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <repo-name> <repo-url>"
    exit 1
fi

# Assign parameters to variables
REPO_NAME=$1
REPO_URL=$2
RULES_FILE="/c/Users/Admin/Desktop/work/rules.pl"
TARGET_DIR="/c/Users/Admin/Desktop/work/$REPO_NAME"

# Clone the repository
echo "Cloning repository from $REPO_URL..."
git clone "$REPO_URL" "$REPO_NAME"
if [ $? -ne 0 ]; then
    echo "Failed to clone repository. Please check the repository URL."
    exit 1
fi

# Navigate into the repository directory
cd "$REPO_NAME" || { echo "Failed to enter directory $REPO_NAME"; exit 1; }

# Configure Gerrit commit-msg hook
echo "Setting up Gerrit commit-msg hook..."
mkdir -p $(git rev-parse --git-dir)/hooks/
curl -Lo $(git rev-parse --git-dir)/hooks/commit-msg http://gerrit.solvendo.io/tools/hooks/commit-msg
chmod +x $(git rev-parse --git-dir)/hooks/commit-msg

# Fetch and check out the meta-config branch
echo "Fetching and checking out meta-config branch..."
git fetch origin refs/meta/config:refs/remotes/origin/meta-config
git checkout meta-config

# Copy the rules.pl file
echo "Copying rules.pl file to $TARGET_DIR..."
cp "$RULES_FILE" "$TARGET_DIR"
if [ $? -ne 0 ]; then
    echo "Failed to copy rules.pl file. Ensure the file exists at $RULES_FILE."
    exit 1
fi

# Add the changes
git add .

# Configure Git user details
echo "Configuring Git user details..."
git config --global user.email "deploy@solvendo.io"
git config --global user.name "solvendo.admin"

# Commit the changes
echo "Committing changes..."
git commit -m "rules.pl file is added"

# Push the changes
echo "Pushing changes to meta-config branch..."
git push origin HEAD:refs/meta/config

# Delete the cloned repository
echo "Deleting cloned repository directory..."
cd ..
rm -rf "$REPO_NAME"

echo "Script executed successfully and repository deleted!"
