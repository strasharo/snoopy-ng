cd $(cat /etc/SNOOP_DIR.conf)

# Downloads the latest files from remote (without trying to merge, rebase, etc)
su -c "git fetch --all" pi

# Resets folder to state of files in branch `origin/master` branch
# Note: Files not tracked by git (e.g. ".DevicenName", ".DeviceLoc", etc) are unaffected
su -c "git reset --hard origin/master" pi

# PS: git commands are run as user 'pi' to avoid any unforeseen issues that may arise from making all files owned by the super user.