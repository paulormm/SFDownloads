#!/bin/bash

VERBOSE=NO
DEBUG=NO
MIRROR=ufpr

RSYNC="/usr/bin/rsync"
URL="sourceforge.net"
EXCLUDE_FILES="--exclude=*.jar*
               --exclude=*.zip*
               --exclude=*.tar*
               --exclude=*.gz*
               --exclude=*.rar*
               --exclude=*.tgz*
               --exclude=*.bz*
               --exclude=*.dll*
               --exclude=*.exe*
               --exclude=*.PNG*
               --exclude=*.png*
               --exclude=*.ico*
               --exclude=*.jpg*
               --exclude=*.JPG*
               --exclude=*.jpeg*
               --exclude=*.gif*
               --exclude=*.bmp*
               --exclude=*.psd*
               --exclude=*.dat*
               --exclude=*.txt*
               --exclude=*.properties*
               --exclude=*.iso*
               --exclude=*.torrent*
               --exclude=*.xml*
               --exclude=*.raw*
               --exclude=*.pdf*
               --exclude=*.doc*
               --exclude=*.odt*
               --exclude=*.tex*
               --exclude=*.css*
               --exclude=*.tmpl*
               --exclude=*.shtml*
               --exclude=*.htm*
               --exclude=*.mf*
               --exclude=*.log*
               --exclude=*.ini*
               --exclude=*.project*
               --exclude=*.classpath*
               --exclude=*.db*
               --exclude=*.config*
               --exclude=*.pat*
               --exclude=*.nsi*
               --exclude=*.js*
               --exclude=*.jni*
               --exclude=*.so*
               --exclude=*.diff*
               --exclude=*.swf*
               --exclude=*.emz*
               --exclude=*.dmg*
               --exclude=*.xsl*
               --exclude=*.xsd*
               --exclude=*.stf*
               --exclude=*.vuze*
               --exclude=*.war*"
EXCLUDE="
               --exclude=CVSROOT
               --exclude=*.cvsignore*
               --exclude=.git
               --exclude=.svn
               --exclude=.bzr
               --exclude=.hg
               $EXCLUDE_FILES"

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
         repository_command="$RSYNC -avz $EXCLUDE
                                    $project.cvs.$URL::cvsroot/$project/* ."
        ;;
        'SVN')
         repository_command="$RSYNC -avz $EXCLUDE
                                    $project.svn.$URL::svn/$project/* ."
        ;;
        'GIT')
         repository_command="$RSYNC -avz $EXCLUDE
                                    $project.git.$URL::gitroot/$project/* ."
        ;;
        'Bazaar')
         repository_command="$RSYNC -avz $EXCLUDE
                                    $project.bzr.$URL::bzrroot/$project/* ."
        ;;
        'Mercurial')
         repository_command="$RSYNC -avz $EXCLUDE
                                    $project.hg.$URL::hgroot/$project/* ."
        ;;
    esac
	
    # I give up!
    if [ -d "$dir_name" ]; then
       debugmsg "$project already downloaded"
       continue
    fi

    mkdir -p "$dir_name"

    pushd "$dir_name" >/dev/null
	 
    debugmsg "$repository_command"
    $repository_command

    if [ $? -gt 0 ]; then
        errmsg "Failed downloading for project $project"
        rm -rf "$dir_name"
    fi

    popd > /dev/null
done
