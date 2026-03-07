set __lsi_dir (begin;pushd (dirname (status --current-filename))/..;pwd;popd;end)
alias ls+="$__lsi_dir/ls+"
alias ls='ls+'
set -e __lsi_dir
