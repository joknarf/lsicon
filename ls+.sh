#!/usr/bin/env bash
# ls+ - enhanced ls with icons and colors
# author: joknarf
# usage: ls+ [ls options]
#

usage() {
    printf "%s\n" "usage: ls+ [-T [-L maxlevel -P <pattern>]] [LSOPTION]... [FILE]...
ls+: ls/tree decorator
ls+ takes same arguments as ls command
Exception:
    -T will display dir/files tree using tree command
    -P <pattern> limit files matching pattern for tree view
    -L <maxlevel> limit tree depth for tree view

To see ls help: \ls --help
"
    exit 0
}
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
skip=false
while [ "$1" ];do
    case "$1" in
        --help|--version) usage "$1";;
        --) break ;;
        --color*always|--color|-C) COLOR=true; shift;continue ;;
        --color*never) COLOR=false; shift;continue ;;
        --color=*|-w|--width*|--zero|-b) shift;continue;;
        --indicator-style*|-m|-N|-p) shift;continue;;
        --time-style*|--quoting-style*|--width*) shift;continue;;
        -g) FLAGS+=(g);shift;continue;;
        -G|--no-group) FLAGS+=(G);shift;continue;;
        -o) FLAGS+=(l G);shift;continue;;
        -l|--format=long) FLAGS+=(l) ;;
        -Z|--context) FLAGS+=(Z) ;;
        -t|-c|-U|-v|-r|-I|-P|-U|-L) ARGSTREE+=("$1");;
        -i|--inode) FLAGS+=(i);ARGSTREE+=(--inodes) ;;
        -h|--human-readable) ARGSTREE+=(-h);;
        -a|--all) ARGSTREE+=(-a);;
        -d|--directory) ARGSTREE+=(-d);;
        --dereference-command-line-symlink-to-dir) ARGSTREE+=(-l);;
        --group-directories-first) ARGSTREE+=(--dirsfirst);;
        -S) ARGSTREE+=(--sort=size);;
        --ignore=*|--hide=*) ARGSTREE+=(-I "${1#*=}");;
        --sort=extension) ;;
        --sort=*) ARGSTREE+=("$1");;
        -1|--format=single-column) FLAGS+=(1) ;;
        --format=*) shift;continue;;
        -s|--size) FLAGS+=(s) ;;
        -n|--numeric-uid-gid) USER_GROUPS=$(id -G); USER_ID=$(id -u);;
        -T|--tree) TREE=true;shift;continue ;;
        -[!-]*)
            a="${1#-}"
            while [ "$a" ];do
                i="${a:0:1}"
                case "$i" in
                a|d|h|t|c|U|v|r|U) ARGSTREE+=(-$i);;
                i) ARGSTREE+=(--inodes);;
                S) ARGSTREE+=(--sort=size);;
                n) USER_GROUPS=$(id -G); USER_ID=$(id -u);;
                T) TREE=true;;
                esac
                [[ $i != [gGT] ]] && ARGS+=(-$i)
                FLAGS+=("${a:0:1}")
                a="${a:1}"
            done
            shift
            continue
        ;;
        [!-]*) ARGSTREE+=("$1");;
        --) break;
    esac
    ARGS+=("$1")
    shift
done
ARGS+=("$@");ARGSTREE+=("$@")
# reversed tree -t
$TREE && [[ " ${ARGSTREE[*]} " = *\ -t\ * ]] && {
    [[ " ${ARGSTREE[*]} " = *\ -r\ * ]] && {
        for ((i=0; i<${#ARGSTREE[@]}; i++));do [ "${ARGSTREE[i]}" = '-r' ] && unset 'ARGSTREE[i]';done
    } || ARGSTREE=(-r "${ARGSTREE[@]}")
}
[ ! "$COLOR" ] && [ ! -t 1 ] && COLOR=false || COLOR=true
! $COLOR && ! $TREE && exec $ls "${ARGSLS[@]}"
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

set -o pipefail
if $TREE ;then
    export LS_COLORS="rs=0:di=0:ln=0:mh=0:pi=0:so=0:do=0:bd=0:cd=0:or=1:mi=0:su=0:sg=0:ca=0:tw=0:ow=0:st=0:ex=0:"
    tree "${ARGSTREE[@]}" |awk -v TERMW="$TERM_COLS" -v FLAGS="${FLAGS[*]}" -v iconfile="$ICON_FILE" -v colorfile="$COLOR_FILE" \
        -v themefile="$THEME_FILE" -v USER="$USER_ID" -v GROUPS="$USER_GROUPS" -f "$LSI/ls+.com.awk" -f "$LSI/ls+.tree.awk"
else
    export LS_COLORS="rs=:di=:ln=:mh=:pi=:so=:do=:bd=:cd=:or=:mi=1:su=:sg=:ca=:tw=:ow=:st=:ex=:"
    $ls -1 "${ARGS[@]}" 2>&1 | awk -v TERMW="$TERM_COLS" -v FLAGS="${FLAGS[*]}" -v iconfile="$ICON_FILE" -v colorfile="$COLOR_FILE" \
        -v themefile="$THEME_FILE" -v USER="$USER_ID" -v GROUPS="$USER_GROUPS" -f "$LSI/ls+.com.awk" -f "$LSI/ls+.awk"
fi