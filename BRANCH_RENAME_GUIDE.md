# Branch Rename Guide: Master to Main

This guide provides step-by-step instructions for renaming the `master` branch to `main` in the Daydream repository.

## Pre-Rename Analysis ✅

**Good News!** The codebase analysis shows:
- ✅ No hardcoded references to "master" branch found in source code
- ✅ No GitHub Actions workflows reference the master branch
- ✅ No configuration files contain master branch dependencies
- ✅ No code changes required after branch rename

## Repository Owner Instructions

### Step 1: Rename the Branch on GitHub

**Option A: Using GitHub Web Interface (Recommended)**
1. Go to the repository: https://github.com/rckim77/Daydream
2. Navigate to the main repository page
3. Click on the branch dropdown (currently showing "master")
4. Click "View all branches"
5. Find the "master" branch and click the edit (pencil) icon
6. Change the name from "master" to "main"
7. Click "Rename branch"

**Option B: Using GitHub CLI**
```bash
# Rename the branch
gh api repos/rckim77/Daydream/branches/master/rename \
  --method POST \
  --field new_name='main'
```

### Step 2: Update Default Branch Setting

1. In GitHub, go to Repository Settings
2. Navigate to "Branches" in the left sidebar
3. Under "Default branch", click the edit button
4. Select "main" as the new default branch
5. Click "Update" and confirm the change

### Step 3: Update Local Development Environment

**For all developers working on this repository:**

```bash
# Switch to master branch
git checkout master

# Fetch the latest changes
git fetch origin

# Rename local master to main
git branch -m master main

# Set up tracking for the new main branch
git branch -u origin/main main

# Verify the change
git status
```

**Alternative one-liner for developers:**
```bash
git checkout master && git fetch origin && git branch -m master main && git branch -u origin/main main
```

### Step 4: Update Any External References

Check and update these if they exist:
- **CI/CD pipelines** that reference "master" (None found in this repo ✅)
- **Documentation** that mentions "master" branch (None found ✅)
- **Clone/checkout scripts** in other projects
- **Deployment scripts** that reference the master branch
- **IDE/editor bookmarks** pointing to master branch

### Step 5: Clean Up Old References

After all team members have updated their local repositories:

```bash
# Delete the old local master branch (if it still exists)
git branch -d master

# Delete the old remote tracking branch
git remote prune origin
```

## Verification Steps

After completing the rename:

1. ✅ Default branch should show "main" on GitHub
2. ✅ New clones should check out "main" by default
3. ✅ All existing pull requests should automatically reference "main"
4. ✅ Repository links should work with "main" branch
5. ✅ No broken references in the codebase (already verified)

## Benefits of This Change

- **Industry Standard**: "main" is now the widely adopted default branch name
- **Inclusive Language**: Aligns with modern best practices
- **Consistency**: Matches new GitHub repository defaults
- **Future-Proof**: Ensures compatibility with evolving industry standards

## Support

If you encounter any issues during the rename process:
1. Check GitHub's official documentation on branch renaming
2. Ensure all team members are aware of the change before proceeding
3. Consider creating a backup branch before starting the process
4. Test the rename process on a fork first if you're unsure

## Timeline Recommendation

1. **Communicate** the planned change to all team members
2. **Schedule** the rename during low-activity periods
3. **Execute** the GitHub rename (takes effect immediately)
4. **Update** all local development environments
5. **Verify** everything is working correctly

---

*This guide was generated as part of issue #45 to ensure a smooth transition from master to main branch.*