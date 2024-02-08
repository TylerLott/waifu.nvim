local M = {}

M.setup = function(opts)

  M.set_args(opts)

  local data_path = vim.fn.stdpath("data")

  local cascade = vim.fn.glob(data_path .. "/*/waifu.nvim/lbp_anime_face_detect.xml")
  print(cascade)
  M.cascade = cascade

  local cache_path = vim.fn.stdpath("cache") .. "/waifu_nvim"
  if vim.fn.isdirectory(cache_path) == 0 then
    vim.fn.mkdir(cache_path)
  end

  M.img_dir = cache_path .. "/waifus"
  local python_dir = cache_path .. "/venv"
  
  -- Activate virtual env
  if vim.fn.isdirectory(python_dir) == 0 then
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
  local script = vim.fn.glob(data_path .. '/*/waifu.nvim/waifu.py')
  print(script)
  M.script = script
  vim.fn.system("python3 " .. M.script .. M.format_args())

  -- Deactivate the virtual environment
  vim.fn.system("deactivate")

end


M.set_args = function(opts)
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
  return " --img_dir " .. M.img_dir .. " --cascade " .. M.cascade
end

M.reload_waifu = function()
  print("loading waifu")
  vim.fn.system("source venv/bin/activate")
  vim.fn.system("python3 " .. M.script_name .. " -g 1")
  vim.fn.system("deactivate")
end

return M
