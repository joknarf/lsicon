#!/usr/bin/env bash
# ls+ - enhanced ls with icons and colors
# author: joknarf
# usage: ls+ [ls options]
#

type gls >/dev/null 2>&1 && ls="gls" || ls="ls"
type gawk >/dev/null 2>&1 && awk="gawk" || awk="awk"
USER_GROUPS=$(id -Gn)
USER_ID=$(id -un)
COLOR=''
ARGSLS=("$@")
ARGS=("-lFQ" "--color" "--time-style=+%y-%m-%d %H:%M")
ARGSTREE=(-pugsDFQ --du --timefmt='%y-%m-%d %H:%M' -C)
FLAGS=()
TREE=false
while [ "$1" ];do
    case "$1" in
        --help|--version) exec ls "$1";;
        --) break ;;
        --color*always|--color) COLOR=true; shift;continue ;;
        --color*never) COLOR=false; shift;continue ;;
        --color=*|-w|--zero|-b) shift;continue;;
        --indicator-style|-m|-N|-p) shift;continue;;
        --time-style|--quoting-style) shift;continue;;
        -g) FLAGS+=(g);shift;continue;;
        -G|--no-group) FLAGS+=(G);shift;continue;;
        -o) FLAGS+=(l G);shift;continue;;
        -l|--format=long) FLAGS+=(l) ;;
        -Z|--context) FLAGS+=(Z) ;;
        -t|-c|-U|-v|-r) ARGSTREE+=($1);;
        -i|--inode) FLAGS+=(i);ARGSTREE+=(--inodes) ;;
        -h|--human-readable) ARGSTREE+=(-h);;
        -a|--all) ARGSTREE+=(-a);;
        -d|--directory) ARGSTREE+=(-d);;
        --dereference-command-line-symlink-to-dir) ARGSTREE+=(-l);;
        --group-directories-first) ARGSTREE+=(--dirsfirst);;
        -S) ARGSTREE+=(--sort=size);;
        -1|--format=single-column) FLAGS+=(1) ;;
        -s|--size) FLAGS+=(s) ;;
        -n|--numeric-uid-gid)
            USER_GROUPS=$(id -G)
            USER_ID=$(id -u)
        ;;
        -T|--tree) TREE=true;shift;continue ;;
        -[!-]*)
            a="${1#-}"
            while [ "$a" ];do
                i="${a:0:1}"
                case "$i" in
                a|d|h|t|c|U|v|r) ARGSTREE+=(-$i);;
                i) ARGSTREE+=(--inodes);;
                S) ARGSTREE+=(--sort=size);;
                n) USER_GROUPS=$(id -G) && USER_ID=$(id -u);;
                T) TREE=true;;
                esac
                [[ $i != [gGT] ]] && ARGS+=(-$i)
                FLAGS+=("${a:0:1}")
                a="${a:1}"
            done
            shift
            continue
        ;;
        *) ARGSTREE+=("$1");;
    esac
    ARGS+=("$1")
    shift
done
[ ! "$COLOR" ] && [ ! -t 1 ] && COLOR=false || COLOR=true
! $COLOR && exec $ls "${ARGSLS[@]}"
[ -r ~/.config/ls+/icons ] && ICON_FILE=~/.config/ls+/icons
[ -r ~/.config/ls+/colors ] && COLOR_FILE=~/.config/ls+/colors
[ -r ~/.config/ls+/theme ] && THEME_FILE=~/.config/ls+/theme
LSI=$(readlink -f $0);LSI=${LSI%/*}
: "${ICON_FILE:=$LSI/ls+.icons}"
: "${COLOR_FILE:=$LSI/ls+.colors}"
: "${THEME_FILE:=$LSI/ls+.theme}"
read _ TERM_COLS <<<$(stty size 2>/dev/null)
: ${TERM_COLS:=80}
# ls is missing an indicator for broken symlink, use color to get it
export LS_COLORS="rs=:di=:ln=:mh=:pi=:so=:do=:bd=:cd=:or=:mi=1:su=:sg=:ca=:tw=:ow=:st=:ex=:"
set -o pipefail
if $TREE ;then
    tree "${ARGSTREE[@]}" |awk -v TERMW="$TERM_COLS" -v FLAGS="${FLAGS[*]}" -v iconfile="$ICON_FILE" -v colorfile="$COLOR_FILE" \
        -v themefile="$THEME_FILE" -v USER="$USER_ID" -v GROUPS="$USER_GROUPS" -f "$LSI/ls+.com.awk" -f "$LSI/ls+.tree.awk"
else
    $ls -1 "${ARGS[@]}" 2>&1 | awk -v TERMW="$TERM_COLS" -v FLAGS="${FLAGS[*]}" -v iconfile="$ICON_FILE" -v colorfile="$COLOR_FILE" \
        -v themefile="$THEME_FILE" -v USER="$USER_ID" -v GROUPS="$USER_GROUPS" -f "$LSI/ls+.com.awk" -f "$LSI/ls+.awk"
fi