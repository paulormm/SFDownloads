#!/bin/bash

VERBOSE=NO
DEBUG=NO
MIRROR=ufpr

RSYNC="/usr/bin/rsync"
URL="sourceforge.net"

errmsg() {
     echo "`basename $0`: $1" >&2
     if [ $# -ne 1 ]; then
         exit $2
     fi
}

debugmsg() {
    if [ "$DEBUG" != "" ]; then
        echo "`basename $0`: $1" >&2
    fi
}

if [ $# -ne 1 -o "$1" == "help" ]; then
    echo
    echo "    `basename $0`: SFDownloads-Repo: download from SourceForge.Net   "
    echo "    the repositories of free software projects."
    echo
    echo "    Given a file, as an argument, with a list of SourceForge.Net     "
    echo "    projects and their type of repositories, according to shown in   "
    echo "    the develop page of each project page at SourceForge.Net, this   "
    echo "    script tries to download a copy of these repositories using rsync"
    echo "    command."
    echo
    echo "    usage: `basename $0` filename"
    echo
    exit 0
fi

[ -x $RSYNC ] || errmsg "$RSYNC not found." -1


cat $1 | while read line; do
    project="`echo "$line" | cut -d, -f1 | sed 's/"//g'`"
    repository_type="`echo "$line" | cut -d, -f2 | sed 's/"//g'`"

    dir_name="$project"

    if [ "$VERBOSE" == "YES" ]; then
        echo "`basename $0`: Downloading project $project from a "
        echo "$repository_type repository"
     fi

    case "$repository_type" in
        'CVS')
         repository_command="$RSYNC -avz $project.cvs.$URL::cvsroot/$project/* ."
        ;;
        'SVN')
         repository_command="$RSYNC -avz $project.svn.$URL::svn/$project/* ."
        ;;
        'GIT')
         repository_command="$RSYNC -avz --exclude '.git' $project.git.$URL::gitroot/$project/* ."
        ;;
        'Bazaar')
         repository_command="$RSYNC -avz --exclude '.bzr' $project.bzr.$URL::bzrroot/$project/* ."
        ;;
        'Mercurial')
         repository_command="$RSYNC -avz $project.hg.$URL::hgroot/$project/* ."
        ;;
    esac
	
    # I give up!
    if [ -d "$dir_name" ]; then
       debugmsg "$project already downloaded"
       continue
    fi

    mkdir -p "$dir_name"

    pushd "$dir_name" >/dev/null
	 
    debugmsg "$repository_command ..."
    $repository_command

    if [ $? -gt 0 ]; then
        errmsg "Failed downloading for project $project"
        rm -rf "$dir_name"
    fi

       popd > /dev/null
done
