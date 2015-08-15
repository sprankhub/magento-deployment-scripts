#!/bin/bash
# Change these variables according to your environment.
SCRIPT_ROOT=/files
HTML_ROOT=/html/shop
HTML_URL=http://page.tld
GIT_URI=git@host.tld:username/repository.git
COMMIT_HASH=HEAD
N98_MAGERUN=${SCRIPT_ROOT}/n98-magerun.phar
MEDIA_ROOT=/html/media

# check if all used commands are allowed in this environment (managed servers often block various commands)
commands="git rm cp ln mv php ${N98_MAGERUN}"

for command in ${commands}
do
    if type -P "${command}" &>/dev/null
    then
        continue
    else
        echo "${command} command not found."
        exit 1
    fi
done

# check if all given directories exist
directories="${SCRIPT_ROOT} ${HTML_ROOT} ${MEDIA_ROOT}"

for directory in ${directories}
do
    if ! test -e "${directory}"
    then
        echo "${directory} command not found."
        exit 1
    fi
done

# get a new, clean version from the repository
echo '... cloning git repository ...'
git clone ${GIT_URI} ${HTML_ROOT}-new
cd ${HTML_ROOT}-new

# checkout files from given commit
echo '... checking out given commit ...'
git checkout ${COMMIT_HASH}
rm -rf .git
cd ..

# put local.xml to new revision
cp ${SCRIPT_ROOT}/local.xml ${HTML_ROOT}-new/app/etc/local.xml
# symlink media directory
ln -s ${MEDIA_ROOT} ${HTML_ROOT}-new/media

# enable maintenance mode
echo '... enabling maintenance mode ...'
> ${HTML_ROOT}/maintenance.flag
> ${HTML_ROOT}-new/maintenance.flag

# copy session files if they are stored in the file system
echo '... copying session files ...'
if test -e ${HTML_ROOT}/var/session/
then
    cp -R ${HTML_ROOT}/var/session/ ${HTML_ROOT}-new/var/session/
fi

# point directory to the new revision
rm -rf ${HTML_ROOT}
mv ${HTML_ROOT}-new ${HTML_ROOT}

cd ${HTML_ROOT}

# clear the cache
echo '... clearing the cache ...'
php ${N98_MAGERUN} cache:flush
# clear the APC cache
php ${SCRIPT_ROOT}/apc_clear_call.php --url=${HTML_URL} --htmlroot=${HTML_ROOT} --scriptroot=${SCRIPT_ROOT}

# run install/upgrade scripts, so that they are executed only once
echo '... running setup scripts ...'
php ${N98_MAGERUN} sys:setup:run

# disable maintenance mode
echo '... disabling maintenance mode ...'
rm maintenance.flag
