set __lsi_dir (path resolve (dirname (status --current-filename))/..)
alias ls+="$__lsi_dir/ls+"
alias ls='ls+'
set -e __lsi_dir
