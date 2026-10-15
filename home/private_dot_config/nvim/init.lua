vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.clipboard = "unnamedplus"
local osc52 = require("vim.ui.clipboard.osc52")
local function paste()
  return { vim.fn.split(vim.fn.getreg('"'), "\n"), vim.fn.getregtype('"') }
end
vim.g.clipboard = {
  name = "OSC 52",
  copy = { ["+"] = osc52.copy("+"), ["*"] = osc52.copy("*") },
  paste = { ["+"] = paste, ["*"] = paste },
}

vim.pack.add{
  { src = 'https://github.com/neovim/nvim-lspconfig' },
  { src = 'https://github.com/folke/tokyonight.nvim' },
  { src = 'https://github.com/nvim-telescope/telescope.nvim' },
  { src = 'https://github.com/nvim-lua/plenary.nvim' },
  { src = 'https://github.com/tpope/vim-sleuth' },
}

local telescope_builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>f', telescope_builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>b', telescope_builtin.buffers, { desc = 'Telescope buffers' })

vim.cmd.colorscheme('tokyonight')
vim.lsp.enable('clangd', 'ruff', 'basedpyright')

vim.diagnostic.config({
  virtual_text = true,
  virtual_lines = { current_line = true },
})

vim.opt.list = true
vim.opt.listchars = {
  tab = '» ',       -- tab: marker, then blank padding to the tab width
  trail = '·',      -- spaces at the end of a line
  nbsp = '␣',       -- non-breaking space (otherwise invisible)
  extends = '›',    -- line continues off-screen to the right (with nowrap)
  precedes = '‹',   -- line continues off-screen to the left
}
