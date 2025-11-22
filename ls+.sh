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
ARGSLS=("$@")
ARGS=("-lFb" "--color=never" "--time-style=+%y-%m-%d %H:%M")
FLAGS=()
while [ "$1" ];do
    case "$1" in
        --help|--version) exec ls "$1";;
        --) break ;;
        --color*always|--color) COLOR=true; shift;continue ;;
        --color*never) COLOR=false; shift;continue ;;
        --color=*|-T|-w|--zero) shift;continue;;
        --indicator-style|-m|-N|-p) shift;continue;;
        --time-style) shift;continue;;
        -g) FLAGS+=(g);shift;continue;;
        -G|--no-group) FLAGS+=(G);shift;continue;;
        -o) FLAGS+=(l G);shift;continue;;
        -l|--format=long) FLAGS+=(l) ;;
        -Z|--context) FLAGS+=(Z) ;;
        -i|--inode) FLAGS+=(i) ;;
        -1|--format=single-column) FLAGS+=(1) ;;
        -s|--size) FLAGS+=(s) ;;
        -n|--numeric-uid-gid)
            USER_GROUPS=$(id -G)
            USER_ID=$(id -u)
        ;;
        -[!-]*)
            [[ "$1" == *n* ]] && USER_GROUPS=$(id -G) && USER_ID=$(id -u)
            a="${1#-}";while [ "$a" ];do FLAGS+=("${a:0:1}");a="${a:1}";done
            [[ "$1" == *[gG]* ]] && ARGS+=("${1//[gG]/}") && shift && continue
        ;;
    esac
    ARGS+=("$1")
    shift
done
ARGS+=("$@")
[ ! "$COLOR" ] && [ ! -t 1 ] && COLOR=false || COLOR=true
! $COLOR && exec $ls "${ARGSLS[@]}"

[ -r ~/.config/ls+/icons ] && ICON_FILE=~/.config/ls+/icons
[ -r ~/.config/ls+/colors ] && COLOR_FILE=~/.config/ls+/colors
[ -r ~/.config/ls+/theme ] && THEME_FILE=~/.config/ls+/theme
: ${ICON_FILE:=${0%/*}/ls+.icons}
: ${COLOR_FILE:=${0%/*}/ls+.colors}
: ${THEME_FILE:=${0%/*}/ls+.theme}
TERM_COLS=$(tput cols) 2>/dev/null
: ${TERM_COLS:=80}

set -o pipefail
$ls -1 "${ARGS[@]}" 2>&1 | awk -v TERMW="$TERM_COLS" -v FLAGS="${FLAGS[*]}" -v iconfile="$ICON_FILE" -v colorfile="$COLOR_FILE" \
    -v themefile="$THEME_FILE" -v USER="$USER_ID" -v GROUPS="$USER_GROUPS" -f ${0%/*}/ls+.awk
