#!/usr/bin/env bash
# ls+ - enhanced ls with icons and colors
# author: joknarf
# usage: ls+ [ls options]
#

type gls >/dev/null 2>&1 && ls="gls" || ls="ls"
type gawk >/dev/null 2>&1 && awk="gawk" || awk="awk"
CONTEXT= INUM= LONG= ONE=
ARGS=()
for a in "$@"; do
    case "$a" in
        --) ARGS+=("$a") ; break ;;
        -l) LONG=1; ARGS+=("$a") ;;
        --format=long) LONG=1; ARGS+=("$a") ;;
        -Z) CONTEXT=1; ARGS+=("$a") ;;
        --context) CONTEXT=1; ARGS+=("$a") ;;
        -i) INUM=1; ARGS+=("$a") ;;
        --inum) INUM=1; ARGS+=("$a") ;;
        -1) ONE=1; ARGS+=("$a") ;;
        -[!-]*) 
            [[ "$a" == *l* ]] && LONG=1
            [[ "$a" == *Z* ]] && CONTEXT=1
            [[ "$a" == *i* ]] && INUM=1
            [[ "$a" == *1* ]] && ONE=1
            ARGS+=("$a")
        ;;
        *) ARGS+=("$a") ;;
    esac
done
COLOR=''
ls_meta_args=("-l" "--quoting-style=escape" "--color=never" "--time-style=+%y-%m-%d %H:%M")
for a in "${ARGS[@]}"; do
    case "$a" in
        --color*always|--color) COLOR=true ; continue ;;
        --color*never) COLOR=false ; continue ;;
        --color=*) continue ;;
        -l|--format=long) continue ;;
        *) ls_meta_args+=("$a") ;;
    esac
done
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
$ls -1 "${ls_meta_args[@]}" 2>&1 | awk -v TERMW="$TERM_COLS" -v LONG_FLAG="$LONG" -v CONT_FLAG="$CONTEXT" \
  -v INUM_FLAG="$INUM" -v ONE_FLAG="$ONE" -v iconfile="$ICON_FILE" -v colorfile="$COLOR_FILE" -v themefile="$THEME_FILE" \
  -f ${0%/*}/ls+.awk
