set __lsi_dir (cd (dirname (status --current-filename))/..; and pwd)
alias ls+="$__lsi_dir/ls+"
alias ls='ls+'
set -e __lsi_dir
