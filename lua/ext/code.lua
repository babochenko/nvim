local Java = require('jdtls')

local Runs = {
  ['lua'] = 'lua',
  ['py'] = 'python3',
  ['sh'] = 'bash',
}

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

}

