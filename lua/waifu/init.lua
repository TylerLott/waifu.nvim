local M = {}

M.setup = function(opts)

  -- create args on M from opts and defaults

  -- create venv if needed
  -- Specify the name of your Python script
  M.set_args(opts)

  -- Create a virtual environment named "venv" in the current directory
  local python_dir = vim.api.nvim_eval('expand("~/.local/share/nvim/lazy/waifu.nvim/venv/")')
  
  local does_python_dir_exist = vim.fn.isdirectory(python_dir)
  print(does_python_dir_exist)
  if does_python_dir_exist == 0 then
    vim.fn.system("python3 -m venv " .. python_dir)

   -- Activate the virtual environment
    vim.fn.system("source " .. python_dir .. "bin/activate")

    -- Install dependencies (if any) from requirements.txt
    vim.fn.system("pip install -r requirements.txt")

    -- Make waifus dir if not exists
    vim.fn.mkdir(M.img_dir)

  else 
   -- Activate the virtual environment
    vim.fn.system("source " .. python_dir .. "bin/activate")
  end

  -- Run the Python script
  M.script = vim.api.nvim_eval('expand("~/.local/share/nvim/lazy/waifu.nvim/waifu.py")')
  vim.fn.system("python3 " .. M.script .. M.format_args())

  -- Deactivate the virtual environment
  print("deactivating pyenv")
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
  return " --img_dir " .. M.img_dir
end

M.reload_waifu = function()
  print("loading waifu")
  vim.fn.system("source venv/bin/activate")
  vim.fn.system("python3 " .. M.script_name .. " -g 1")
  vim.fn.system("deactivate")
end

return M
