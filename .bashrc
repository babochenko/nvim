function gd() {
    nvim -c "DiffviewOpen HEAD"
}

function gh() {
    local file="$1"
    nvim -c "DiffviewFileHistory $file"
}

