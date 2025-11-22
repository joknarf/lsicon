#!/usr/bin/env bash
# ls+ - enhanced ls with icons and colors
# author: joknarf
# usage: ls+ [ls options]
#

type gls >/dev/null 2>&1 && ls="gls" || ls="ls"
type gawk >/dev/null 2>&1 && awk="gawk" || awk="awk"
CONTEXT= INUM= LONG= ONE= SIZEB=
USER_GROUPS=$(id -Gn)
USER_ID=$(id -un)
COLOR=''
ARGS=("-lFb" "--color=never" "--time-style=+%y-%m-%d %H:%M")
FLAGS=()
while [ "$1" ];do
    echo "$1"
    case "$1" in
        --) break ;;
        --color*always|--color) COLOR=true; shift;continue ;;
        --color*never) COLOR=false; shift;continue ;;
        --color=*) shift;continue;;
        -l|--format=long) LONG=1 ;;
        -Z|--context) CONTEXT=1 ;;
        -i|--inode) INUM=1 ;;
        -1|--format=single-column) ONE=1 ;;
        -s|--size) SIZEB=1 ;;
        -n|--numeric-uid-gid)
            USER_GROUPS=$(id -G)
            USER_ID=$(id -u)
        ;;
        -[!-]*) 
            [[ "$1" == *l* ]] && LONG=1
            [[ "$1" == *Z* ]] && CONTEXT=1
            [[ "$1" == *i* ]] && INUM=1
            [[ "$1" == *1* ]] && ONE=1
            [[ "$1" == *s* ]] && SIZEB=1
            [[ "$1" == *n* ]] && USER_GROUPS=$(id -G) && USER_ID=$(id -u)
        ;;
    esac
    ARGS+=("$1")
    shift
done
ARGS+=("$@")
[ ! "$COLOR" ] && [ ! -t 1 ] && COLOR=false || COLOR=true
! $COLOR && exec $ls "$@"

[ -r ~/.config/ls+/icons ] && ICON_FILE=~/.config/ls+/icons
[ -r ~/.config/ls+/colors ] && COLOR_FILE=~/.config/ls+/colors
[ -r ~/.config/ls+/theme ] && THEME_FILE=~/.config/ls+/theme
: ${ICON_FILE:=${0%/*}/ls+.icons}
: ${COLOR_FILE:=${0%/*}/ls+.colors}
: ${THEME_FILE:=${0%/*}/ls+.theme}
TERM_COLS=$(tput cols) 2>/dev/null
: ${TERM_COLS:=80}

set -o pipefail
$ls -1 "${ARGS[@]}" 2>&1 | awk -v TERMW="$TERM_COLS" -v LONG_FLAG="$LONG" -v CONT_FLAG="$CONTEXT" -v SIZEB_FLAG="$SIZEB" \
  -v INUM_FLAG="$INUM" -v ONE_FLAG="$ONE" -v iconfile="$ICON_FILE" -v colorfile="$COLOR_FILE" -v themefile="$THEME_FILE" \
  -v USER="$USER_ID" -v GROUPS="$USER_GROUPS" -f ${0%/*}/ls+.awk
