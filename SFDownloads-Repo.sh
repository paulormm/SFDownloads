#!/bin/bash

VERBOSE=NO
DEBUG=NO
MIRROR=ufpr

if [ x$1 == x -o "$1" == "help" ]; then
    echo
    echo "    `basename $0`: SFDownloads-Repo: download from SourceForge.Net the repositories of free software projects"
    echo
    echo "    Given a file, as an argument, with a list of SourceForge.Net projects and their"
    echo "    type of repositories, according to shown in the develop page of each project page"
    echo "    at SourceForge.Net, this script tries to download a copy of these"
    echo "    repositories using rsync command."
    echo
    echo "    usage: `basename $0` filename"
    echo
    exit 0
fi

errmsg() {
    echo "`basename $0`: $1" >&2
}

debugmsg() {
    if [ x$DEBUG != x ]; then
        echo "`basename $0`: $1" >&2
    fi
}

cat $1 | while read line; do
    project_name="`echo "$line" | cut -d, -f1 | sed 's/"//g'`"
    repository_type="`echo "$line" | cut -d, -f2 | sed 's/"//g'`"

    dirname="$project_name"

    if [ $VERBOSE == YES ]; then
        echo "`basename $0`: Downloading project $project_name from a $repository_type repository"
    fi

    case "$repository_type" in
        'CVS')
          repository_command="rsync -av $project_name.cvs.sourceforge.net::cvsroot/$project_name/* ."
        ;;
        'SVN')
          repository_command="rsync -av $project_name.svn.sourceforge.net::svn/$project_name/* ."
        ;;
        'GIT')
          repository_command="rsync -av --exclude '.git' $project_name.git.sourceforge.net::gitroot/$project_name/* ."
        ;;
        'Bazaar')
          repository_command="rsync -av --exclude '.bzr' $project_name.bzr.sourceforge.net::bzrroot/$project_name/* ."
        ;;
        'Mercurial')
          repository_command="rsync -av $project_name.hg.sourceforge.net::hgroot/$project_name/* ."
        ;;
    esac
	
    # I give up!
    if [ -d "$dirname" ]; then
       debugmsg "$project_name already downloaded"
       continue
    fi

       mkdir -p "$dirname"

       pushd "$dirname" >/dev/null
	 
       debugmsg "$repository_command ..."
       $repository_command

       err=$?
       if [ $err -gt 0 ]; then
          errmsg "Failed downloading for project $project_name"
	  rm -rf "$dirname"
       fi

       popd > /dev/null
done
