# Waifu.nvim

Greet a new waifu each day when opening nvim in iterm2

## Requires
- python3

## Usage

lazy.nvim
'''
local M = {
  "TylerLott/waifu.nvim"
}

function M.config()
  require("waifu").setup({ })
end

return M
'''

## Options

defaults
'''
opts = {
"debug" = false,
"type" = "sfw",
"category" = "waifu",
"blending" = 0.15,
"image_mode" = "fill",
"crop" = 1,
"width" = 16,
"height" = 12,
}
'''

### type 
- "sfw"
- "nsfw"

### category
- waifu
- neko
- shinobu
- megumin
- bully
- cuddle
- cry
- hug
- awoo
- kiss
- lick
- pat
- smug
- bonk
- yeet
- blush
- smile
- wave
- highfive
- handhold
- nom
- bite
- glomp
- slap
- kill
- kick
- happy
- wink
- poke
- dance
- cringe

### blending
iTerm2 image blending (0 = transparent, 1 = opaque)

### image_mode
- "fill"
- "stretch"
- "fit"
- "tile"

### crop
- 0 = no crop
- 1 = crop to aspect ratio of width and height
- 2 = try to crop to the face

