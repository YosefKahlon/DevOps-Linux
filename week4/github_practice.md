# Week 4 – Daily Practice Tasks 
---


# Branching & Switching 
This commnad create a new local Git repository and initialize it 
```bash
git inti
```
This commnad initialize, create new branch named master.
Before we can create new branches we must commit to this branch:

```bash
touch README.md
git add README.md
git commit -m "Initial commit with README"
```
Now we are able to create two branches (`feature-a` and `feature-b`).

```bash
git branch feature-a
git branch feature-b
```

 For switch branch we can use: 

 ```bash
 git branch feature-a
 git branch feature-a
 ```

Now lest update and commit each of them:
```bash
git commit -m "update readme"
```
-----------------

# Simulate and Resolve Merge Simulate 


To simulate a merge conflict between two branches, we’ll create the same file in both branches and modify the same line differently in each one.

Step 1: Create and modify the file in feature-a
```bash
git switch feature-a
touch file.txt
echo same line feature-a >> file.txt
git add .
git commit -m "file.txt in feature-a"
```
Step 2: Create and modify the same file in feature-b
```bash
git switch feature-b
touch file.txt
echo same line feature-b >> file.txt
git add .
git commit -m "file.txt in feature-b"
```
Step 3: Merge feature-a into feature-b
```bash
git merge feature-a
```
You should now see a merge conflict message:
```bash
Auto-merging file.txt
CONFLICT (add/add): Merge conflict in file.txt
Automatic merge failed; fix conflicts and then commit the result.
```
Step 4: Resolve the Conflict
Open file.txt in any text editor. It will look like this:
```bash
<<<<<<< HEAD
same line feature-b
=======
same line feature-a
>>>>>>> new_branch_to_merge_later
```
This means:
* The current changes from your branch (feature-b) are under <<<<<<< HEAD.
* The incoming changes from the branch you're merging (feature-a) are under ======= to >>>>>>>.

Step 5: Edit the file to resolve the conflict
Choose one version or manually combine them.
Make sure to remove the Git conflict markers (<<<<<<<, =======, >>>>>>>).

Step 6: Finalize the merge
```bash
git file.txt
git commit -m "Resolve merge conflict between feature-a and feature-b"
```
-------------------

# Rebase and Cherry-Pick 


Step 1: Rebase feature-a onto main
```bash
# Make sure master is up to date
git checkout master

# Switch to feature-a
git checkout feature-a

# Rebase feature-a onto master
git rebase master
```

What happens to the commit history?
Git takes all the commits from feature-a that are not in master and re-applies them on top of the latest commit in master.

The commit SHAs in feature-a change, because Git "rewrites history" during rebase.

The history becomes linear — it looks as if the work in feature-a started after the latest commit in main.

Step 2: Cherry-pick a commit from feature-b to master

Switch to master:
```bash
git checkout master
```

Get the commit SHA you want to cherry-pick:
```bash
git log feature-b
```
You should see something like:

```bash
commit a30629772f5bebcfb84c2a39aba31a81cc5f2c47 (feature-b)
Author: Yosef <yosefkahlon53@gmail.com>
Date:   Mon May 26 12:43:25 2025 +0300

    cherry file

....
```
Apply that single commit:

```bash
git cherry-pick a30629772f5bebcfb84c2a39aba31a81cc5f2c47 
```

Confirm that the cherry-pick worked:

```bash
git log master
```
You should now see:
``` bash
commit b9aea8259b8847d43c82ecfc15e3338c2b069ab8 (HEAD -> master)
Author: Yosef <yosefkahlon53@gmail.com>
Date:   Mon May 26 12:43:25 2025 +0300

    cherry file

```
This means the commit from feature-b has been successfully applied to master, with a new SHA.




What are the difference between `rebase` and `merge`:

`merge` combines the work from two branches and keeps the original history — it shows how the work was combined and when. It’s safer and better for collaborative work, but can make the history messy.

`rebase` takes the changes from your branch and replays them as if they were created on top of the latest commit from the target branch. This creates a clean, straight history, but rewrites the past and should be used carefully.



# Stash, Amend, and Cleanup 

- Step 1: Stash Local Changes
We made local changes to a file and used git stash to temporarily save them without committing:
```bash
git stash push -m "Temporary changes to file.txt"
```
This removed the changes from the working directory and saved them in the stash stack.


- Step 2: Restore Stashed Changes
We restored the stashed changes using:
```bash
git stash pop
```
This reapplied the latest stash to the working directory and removed it from the stash list.

Step 3: Amend the Last Commit
After making additional edits and staging them:
```bash
git add file.txt
```
We amended the last commit to include the new changes:
```bash
git commit --amend
```
This updated the last commit with the new content without creating a new commit. It also allowed editing the commit message if needed.

- Step 4: Clean Up Merged Local Branches
To keep the repository clean, we listed and deleted local branches that had already been merged into main:
```bash
git branch --merged main #lists all the local branches that have already been fully merged into the main branch.

git branch -d feature-a
git branch -d feature-b
```
