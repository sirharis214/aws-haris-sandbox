# GitHub

# git | downloading and configuring
Downloads Link: `https://git-scm.com/downloads`

## git | Download
### MacOS
Choose your method of downloading git from [git-scm.com/mac](https://git-scm.com/download/mac).

### Windows
Download the git installer from [git-scm.com/win](https://git-scm.com/download/win). 

Follow the steps in the installer. You might find this guide helpful from [phoenixnap.com](https://phoenixnap.com/kb/how-to-install-git-windows).

* Be sure to opt in for Git Credential Manager Core, we'll be needing that later on.

## git | Configure
### global username and email
Once you download git, configure the global username and global email shown below.

* For Windows, open the Git Bash application and follow along. 
* For macOS, open your normal terminal and follow along

```shell
$ git config --global user.name "<YOUR_GITHUB_USERNAME>"
$ git config --global user.email "<YOUR_GITHUB_EMAIL>"
```

> You can update or view these user and email settings under "~/.gitconfig" for mac and "C:\Users\<username>\.git-credentials" for windows

## git | Credential Helper 
It can be a tedious task to constantly enter your GitHub credentials manually in order to use your git cli with GitHub. Below are the steps to configure git cli with a GitHub PAT so your always able to use the git command without having to manually authenticate. 

First step is to create a GitHub PAT for yourself from the GitHub console. This will be your unique access token used to auth into GitHub. This first step is the same regardless of the OS your on.

* GitHub console > Settings > Developer Settings > Personal access tokens > Tokens (classic)
    - Having just the first option, **repo** level permissions should be enough

> :warning: Keep PAT safe and secure, you will not be able to view this token a second time so copy it and paste it in a secure place for now

### MacOS

1. Update the gitconfig file to use credential helper
    - `vi ~/.gitconfig`
    - You should see a **user** section with the user and email which was added in the previous section
2. Under the user section, add a section called `credential` and add `helper = store`, it should look like this:

```shell
$ cat ~/.gitconfig
[user]
	name = YOUR_GITHUB_USERNAME
	email = YOUR_GITHUB_EMAIL
[credential]
	helper = store
```

3. Now create a file called `.git-credentials`
    - `touch ~/.git-credentials`
4. Update .git-credentials with the following contents
    - `https://<YOUR_GITHUB_USERNAME>:<PAT>@github.com`
5. Try to run a git command that would require you to auth into github
    - you might have to manually auth in the one time but from there on out it shouldn't prompt you anymore

### Windows
1. Run the following commands to configure credential helper on Windows

```shell
# set you username
git config --global credential.username YOUR_GITHUB_USERNAME
# set credential.helper 
git config --global credential.helper store
```
2. Next time you do a git command that requires you to authenticate into GitHub, such as `git push`, use the PAT token as the password.
3. Every time after this you won't be asked to auth into GitHub manually.

When you update your GitHub PAT from the console, and you want to update it in the local credential helper as well, you must follow these commads.

```shell
# unset credential.helper
git config --global --unset-all credential.helper
# re-set credential.helper 
git config --global credential.helper store
```
* Next time you do a git command that requires you to authenticate into GitHub, such as `git push`, use the New PAT token as the password.

# GitHub Repository Branches
Theres a strict branch flow to follow for each GitHub repository. This branching flow is beneficial for maintaining a structured and controlled development process, ensuring that code is thoroughly tested at each stage before reaching production. It provides a clear path for collaboration, reduces conflicts, and enhances the overall stability of the codebase.

# New Repository Steps 
From the GitHub console, when you create a new repository, create these branches right away.

1.	Create a new repo – include README.md 
    - by default it add's the name of the repo in the README
2.	Create a branch off main called **staging**
    - click the branch dropdown and confirm your on main
    - type the name of the new branch: `staging`
    - then choose: "create branch staging from main"
3.	Create a branch off staging called **dev**
    - click the branch dropdown and confirm your on staging
    - type the name of the new branch: `dev`
    - then choose: "create branch dev from staging"

# Merge flow
You should never merge any of the top 3 branches into each other. Think of them as isolated baskets that cannot sit on top of each other. We will use **feature** branches which will merge between the isolated baskets, so the Repo’s activity tree is clear and concise. 

## Feature branch creation
Generally, you want to write code in each feature branch for a specific change or update. You don’t want to bulk up a single feature branch with every single change or update that you want to bring into testing or prod. 

You will always create feature branches off **staging** with the naming convention of `feature/<feature_name>”`

1. From your Code editor or terminal, checkout your staging branch
    - `git checkout staging`
2. Pull all updates
    - `git pull` or `git pull origin staging`
3. Create feature branch off staging
    - `git checkout -b feature/create-s3-bucket`
4. Write the code for this new feature and push updates regularly to the branch
    - be sure to write clear and brief commit messages

## Feature branch flow 
1. Create the feature branch for feature-1 as mentioned above
2. Write your code for a specific feature that you want to work on
3. From GitHub Console, open a Pull Request (PR) to merge **feature -> dev**
    - for best practice, allow peers to review your work before you accept the PR and perform the merge
4. Merge this feature branch to dev branch
5. Test the dev branch code in a sandbox environment
6. If everything looks good, your changes work as expected and haven’t broken anything then move to next step
    - If you forgot to add something or found a bug in your feature code, it is okay at this phase to update your existing feature branch and merge it into “dev” to continue testing
7. Once your testing is done, open a PR to merge **feature -> staging**
    - Peer review usually isn’t needed here since they already reviewed the feature code during PR for feature -> dev
8. NOW feature-1 is completed and merged into staging, 
    - you can delete the feature branch from GitHub console
    - from code editor or terminal, checkout staging and pull the updates 
    - create another feature branch off staging to now work on feature-2 and follow the process again

If you are working in a colab environment with other dev’s, it’s okay for you both to create feature branches off staging at the same time even though you are working on different features. GitHub will be able to detect the lines you worked on and if you made changes to the same file, GitHub would attempt to merge both feature’s code on the same file. 

There is a possibility for conflicts, see [handling merge conflicts](#handling-merge-conflict) to see how to handle merge conflicts during Pull Requests (PR’s)

# Production Release 
Once there are a good number of features added into staging, you can decide as a team to put out a prod update. There’s a very specific branch flow for this as well:
1. Create a release candidate branch off staging with the naming convention of `rc-<version_number>`
2. Create a PR to merge **rc-x.x.x -> main**
    - Allow peers to review the code changes expected 
3. After PR is approved, merge rc-x.x.x to main
4. Create your release tag on the main branch
5. Delete the rc branch from GitHub console

# Handling Merge Conflict
A merge conflict is bound to happen, if a feature branch gets created off any other branch other than staging, if an older feature branch is being used with new code, if multiple feature branches with over lapping commits to the same file are made and GitHub can’t figure out how to perform the merge, any of this common reason can cause a merge conflict. We want to make sure we handle the merge conflict the proper way to avoid any future conflicts and to make sure there’s no corruption to our 3 base branches (main, dev, staging)

When you’re creating a PR you might come across a situation where GitHub warns you that there’s a merge conflict, you can still create the PR but you will have to resolve the conflicts in order to actually perform the merge. From the console, GitHub will allow you to use the GitHub editor to resolve conflicts, but we do NOT want to do this.

When you resolve conflicts using the console editor in the PR, behind the scenes GitHub will make a merge from the branch you’re trying to merge to back into feature branch, this is considered a backwards merge. Later this feature branch will have to be merged into staging but now the history would include a dev branch. Remember at the beginning of the document I mentioned we want to treat main, staging and dev branches as isolated baskets that should never merge into each other. If we continued with this feature branch with a backwards merge with dev, all new feature branches will always cause merge conflicts during PR’s which will become VERY annoying.

## How you want to resolve merge conflicts

### feature -> dev
If you opened a PR to do a **feature -> dev** and a merge conflict occurs:

In your code editor, checkout the branch you are trying to merge into, which in this case is the dev branch. From the GitHub console, check where the conflicts are occurring and in your code editor, update those conflicts directly in the dev branch you have checked out. Once you have updated the files where the conflicts are occurring, push those changes directly back into dev branch. Now the PR will have detected an update on dev branch and update, either all conflicts are resolved, or you have more changes to make in dev branch.

### feature -> staging
if you opened a PR to do a **feature -> staging** and a merge conflict occurs:

Chances are your feature branch is behind staging meaning new updates had been pushed to staging during the time you first created this feature branch. Even if you added new code to the feature branch, the history conflicts because the base of your feature branch is linked to an older version of staging. In this case you might have to do a merge staging -> feature to update feature branch and then IF your work didn’t get overwritten, merge feature -> staging again. I would first try do to the same method as feature -> dev where in this case you would checkout staging branch in your code editor, update the conflicts directly in staging branch with the code your feature is trying to merge push these changes directly into staging branch.

If your feature branch wasn’t too lengthy and you don’t mind doing some work, I would just create a new feature branch off staging and start over. 
* Always make sure when creating feature branches that you are first checkout out staging branch and that you are pulling for all updates

### rc-x.x.x -> main
If you open a PR to do a **rc-x.x.x -> main** and a merge conflict occurs:

Chances are your staging and main branch are out of sync. Main branch is always source of truth and prevails on all other branches. So, in this case, there might be some possibility of damage that occurs but it’s for the greater good, merge main -> staging. This should not be done frequently as a main -> staging merge not only looks bad in the history tree but can cause major issues for complicated staging environments.

# Numbering Convention for Release Versioning
Sub minors go all the way to .99, Usually we create the very first version with a version number 0.0.1.

In general for the typical X.X.X version use:

* v1.2.3 
    - 1 is Major
    - 2 is Minor
    - 3 is Sub-Minor
 
* Major would be for breaking changes
* Minor for new features
* Sub-Minor is for Patch, bug fixes

# git | common commands
```shell
# clone a repository from GitHub
git clone https://github.com/sirharis214/aws-haris-sandbox.git

# list all branches
git branch --all

# change between branches
git checkout BRANCH_NAME

# create a new branch
git checkout -b NEW_BRANCH_NAME

# pull updates for current branch from remote
git pull  # or git pull origin BRANCH_NAME

# once your ready to push branch updates to remote
git status
git add --all  # or git add FILE_NAME you wish to push
git commit -m "brief message on updates or changes for commit"
git push origin BRANCH_NAME

# delete branch that has not been commited
git branch -d BRANCH_NAME

# delete branch by force because it has been commited
git branch -D BRANCH_NAME
```
