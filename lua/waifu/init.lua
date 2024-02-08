local M = {}

M.setup = function(opts)

  -- create args on M from opts and defaults

  -- create venv if needed
  -- Specify the name of your Python script
  M.script_name = "waifu.py"
  M.set_args(opts)

  -- Create a virtual environment named "venv" in the current directory
  if not vim.fn.isdirectory("py_env") then
    vim.fn.system("python3 -m venv venv")

   -- Activate the virtual environment
    vim.fn.system("source venv/bin/activate")

    -- Install dependencies (if any) from requirements.txt
    vim.fn.system("pip install -r requirements.txt")

  else 
   -- Activate the virtual environment
    vim.fn.system("source venv/bin/activate")
  end

  -- Run the Python script
  vim.fn.system("python3 " .. M.script_name .. M.format_args(opts))

  -- Deactivate the virtual environment
  vim.fn.system("deactivate")

end


M.set_args = function(opts)
  if opts["img_dir"] then
    M.img_dir = opts["img_dir"]
  else 
    M.img_dir = vim.api.nvim_eval('expand("~/.local/share/nvim/lazy/waifu.nvim/waifus/")') 
  end

  if opts["type"] then
    M.type = opts["type"]
  else
    M.type = "sfw"
  end

  if opts["category"] then
    M.category = opts["category"]
  else
    M.category = "waifu"
  end

  if opts["blending"] then
    M.blending = opts["blending"]  
  else
    M.blending = 0.15
  end
end

M.format_args = function()
  return "--img_dir " .. M.img_dir
end

M.reload_waifu = function()
  vim.fn.system("source venv/bin/activate")
  vim.fn.system("python3 " .. M.script_name .. " " .. M.format_args(opts) .. " -g 1")
  vim.fn.system("deactivate")
end

return M
