local dingllm = require 'dingllm'

local M = {}

M.run_help = function()
  dingllm.invoke_llm_and_stream_into_editor({
    url = 'https://api.openai.com/v1/chat/completions',
    api_key_name = 'OPENAI_API_KEY',
    model = 'gpt-4o',
    system_prompt = "You are a helpful assistant",
    replace = false,
  }, dingllm.make_openai_spec_curl_args, dingllm.handle_openai_spec_data)
end

M.run_completion = function()
  dingllm.invoke_llm_and_stream_into_editor({
    url = 'https://api.openai.com/v1/chat/completions',
    api_key_name = 'OPENAI_API_KEY',
    model = 'gpt-4o',
    system_prompt = "respond with code only. Don't format as markdown",
    replace = true,
  }, dingllm.make_openai_spec_curl_args, dingllm.handle_openai_spec_data)
end

return M

