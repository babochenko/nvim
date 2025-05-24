local Java = require('jdtls')

local Runs = {
  ['lua'] = 'lua',
  ['py'] = 'python3',
  ['java'] = 'java --enable-preview',
  ['sh'] = 'bash',
  ['zsh'] = 'zsh',
}

local function format_file()
    local filename = vim.api.nvim_buf_get_name(0)
    local ext = vim.fn.expand('%:e')

    -- Check if we have a visual selection
    local mode = vim.fn.mode()
    local has_selection = mode == 'v' or mode == 'V'

    -- Prompt for extension if file is unsaved
    if filename == '' or ext == '' then
        ext = vim.fn.input('Enter file extension (e.g., html, css, js): ')
        if ext == '' then
            print('No extension provided, aborting.')
            return
        end
    end

    if has_selection then
        -- Get selected line range
        local start_line = vim.fn.line("'<")
        local end_line = vim.fn.line("'>")
        local cmd = start_line .. ',' .. end_line .. '!'
        vim.cmd(cmd .. 'prettier --parser ' .. ext)
    else
        -- Whole file
        vim.cmd('%!prettier --parser ' .. ext)
    end

    print('Formatted with Prettier.')
end

return {

  test_func = function()
    Java.test_nearest_method()
  end,

  test_file = function()
    Java.test_class()
  end,

  run_file = function()
    local file_path = vim.fn.expand('%:p')
    local file_extension = vim.fn.expand('%:e')

    local cmd = Runs[file_extension]
    if cmd == nil then
        print('No command defined for this file type')
        return
    end

    cmd = cmd .. ' ' .. file_path
    vim.cmd('terminal')
    vim.cmd('startinsert')
    vim.fn.chansend(vim.b.terminal_job_id, cmd .. '\n')
  end,

  format_file = format_file,
}

