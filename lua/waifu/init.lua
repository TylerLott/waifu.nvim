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
  
  local running_script = ""

  -- Activate virtual env
  if vim.fn.isdirectory(M.python_dir) == 0 then
    M.P("Creating new venv")
    running_script = running_script .. "python3 -m venv " .. M.python_dir .. " "
    running_script = running_script .. "&& source " .. M.python_dir .. "/bin/activate "
    running_script = running_script .. "&& pip install -r requirements.txt "
  else 
   -- Activate the virtual environment
    M.P("Using existing venv")
    running_script = running_script .. "source " .. M.python_dir .. "/bin/activate"
  end
  
  -- Make waifus dir if not exists
  if vim.fn.isdirectory(M.img_dir) == 0 then
    vim.fn.mkdir(M.img_dir)
  end

  -- Run the Python script
  M.script = vim.fn.glob(data_path .. '/*/waifu.nvim/waifu.py')
  M.P("Running script from " .. M.script)
  M.P("Running with args: " .. M.format_args())
  running_script = running_script .. "&& python3 " .. M.script .. M.format_args()

  -- Deactivate the virtual environment
  running_script = running_script .. "&& deactivate"

  -- Run script
  local output = vim.fn.system(running_script)
  M.P("Script output: " .. output)
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
  args = args .. " -z " .. M.cascade
  args = args .. " -t " .. M.type
  args = args .. " -c " .. M.category
  args = args .. " -b " .. M.blending
  args = args .. " -m " .. M.image_mode
  args = args .. " -r " .. M.crop
  args = args .. " -x " .. M.width
  args = args .. " -y " .. M.height
  args = args .. " -v 1 " -- always run python verbose
  return args
end

M.reload_waifu = function()
  print("loading waifu")
  local running_script = "source " .. M.python_dir .. "/bin/activate"
  running_script = running_script .. "&& python3 " .. M.script .. M.format_args() .. "-g 1"
  running_script = running_script .. "&& deactivate"

  local output = vim.fn.system(running_script)
  M.P("Script output: " .. output)
  print("done loading waifu")
end

vim.cmd([[command! NewWaifu lua require'waifu'.reload_waifu()]])

return M
