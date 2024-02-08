local M = {}

M.P = function(value)
  if M.debug == true then
    print(value)
  end
end

M.setup = function(opts)

  M.set_args(opts)

  local data_path = vim.fn.stdpath("data")

  local cascade = vim.fn.glob(data_path .. "/*/waifu.nvim/lbp_anime_face_detect.xml")
  M.cascade = cascade

  local cache_path = vim.fn.stdpath("cache") .. "/waifu_nvim"
  if vim.fn.isdirectory(cache_path) == 0 then
    vim.fn.mkdir(cache_path)
  end

  M.img_dir = cache_path .. "/waifus"
  M.python_dir = cache_path .. "/venv"
  
  -- Activate virtual env
  if vim.fn.isdirectory(M.python_dir) == 0 then
    M.P("Creating new venv")
    vim.fn.system("python3 -m venv " .. M.python_dir)

   -- Activate the virtual environment
    vim.fn.system("source " .. M.python_dir .. "bin/activate")

    -- Install dependencies (if any) from requirements.txt
    vim.fn.system("pip install -r requirements.txt")

    -- Make waifus dir if not exists
    vim.fn.mkdir(M.img_dir)

  else 
   -- Activate the virtual environment
    M.P("Using existing venv")
    vim.fn.system("source " .. M.python_dir .. "bin/activate")
  end

  -- Run the Python script
  M.script = vim.fn.glob(data_path .. '/*/waifu.nvim/waifu.py')
  M.P("Running script from " .. M.script)
  M.P("Running with args: " .. M.format_args())
  vim.fn.system("python3 " .. M.script .. M.format_args())

  -- Deactivate the virtual environment
  vim.fn.system("deactivate")

end


M.set_args = function(opts)
  if opts["debug"] then
    M.debug = opts["debug"]
  else
    M.debug = false
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

  if opts["image_mode"] then
    M.image_mode = opts["image_mode"]
  else 
    M.image_mode = "fill"
  end

  if opts["crop"] then
    M.crop = opts["crop"]
  else
    M.crop = 1
  end

  if opts["width"] then
    M.width = opts["width"]
  else
    M.width = 16
  end

  if opts["height"] then
    M.height = opts["height"]
  else 
    M.height = 12
  end
end

M.format_args = function()
  local args = " -i " .. M.img_dir 
  args = args .. " -x " .. M.cascade
  args = args .. " -t " .. M.type
  args = args .. " -c " .. M.category 
  args = args .. " -b " .. M.blending
  args = args .. " -m " .. M.image_mode 
  args = args .. " -c " .. M.crop
  args = args .. " -x " .. M.width
  args = args .. " -y " .. M.height
  return args
end

M.reload_waifu = function()
  print("loading waifu")
  vim.fn.system("source " .. M.python_dir .. "bin/activate")
  vim.fn.system("python3 " .. M.script .. M.format_args() .. " -g 1")
  vim.fn.system("deactivate")
  print("done loading waifu")
end

vim.cmd([[command! NewWaifu lua require'waifu'.reload_waifu()]])

return M
