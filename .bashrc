function gd() {
    nvim -c "DiffviewOpen HEAD"
}

function gh() {
  local file="" mode="history" arg=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -c|--commit) mode="commit"; arg="$2"; shift 2;;
      -r|--range)  mode="range";  arg="$2"; shift 2;;
      *) file="$1"; shift;;
    esac
  done
  local cmd=""

  if [[ "$mode" == "commit" ]]; then
    # show just that commit for the file
    cmd="DiffviewOpen ${arg}^! -- $file"

  elif [[ "$mode" == "range" ]]; then
    # show for range - e.g. a1b2c3d^..HEAD
    cmd="DiffviewFileHistory --range=${arg} -- $file"

  else
    # full history
    cmd="DiffviewFileHistory -- $file"
  fi

  if [[ -n "$file" && -f "$file" ]]; then
      cmd="$cmd | DiffviewToggleFiles"
  fi

  nvim -c "$cmd"
}

function ipy() {
     venv; ipython --TerminalInteractiveShell.editing_mode=vi
}

git config --global alias.s status
git config --global alias.g \
"log --graph --oneline --decorate --date=format:'%Y-%m-%d %H:%M' --pretty=format:'%C(auto)%h %Cgreen%ad %C(auto)%d %s'"

