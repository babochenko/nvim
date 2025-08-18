function gd() {
    nvim -c "DiffviewOpen HEAD"
}

function gh() {
    local file="$1"
    nvim -c "DiffviewFileHistory $file"
}

function ipy() {
     venv; ipython --TerminalInteractiveShell.editing_mode=vi
}

git config --global alias.s status
git config --global alias.g \
"log --graph --oneline --decorate --date=format:'%Y-%m-%d %H:%M' --pretty=format:'%C(auto)%h %Cgreen%ad %C(auto)%d %s'"

