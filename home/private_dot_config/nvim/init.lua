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
  'https://github.com/neovim/nvim-lspconfig',
  'https://github.com/folke/tokyonight.nvim',
  'https://github.com/nvim-telescope/telescope.nvim',
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/tpope/vim-sleuth',
  'https://github.com/lewis6991/gitsigns.nvim',
  { src = 'https://github.com/Saghen/blink.cmp', version = vim.version.range('1.*') },
}

vim.lsp.config('emmylua_ls', {
settings = {
    emmylua = {
      runtime = { version = 'LuaJIT' },
      diagnostics = { globals = { 'vim' } },
      workspace = { library = { vim.env.VIMRUNTIME } },
    },
  },
})

vim.lsp.enable({'clangd', 'ruff', 'basedpyright', 'emmylua_ls'})

require('blink.cmp').setup()

local telescope_builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>f', telescope_builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>b', telescope_builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>ds', telescope_builtin.lsp_document_symbols, { desc = 'Document symbols' })
vim.keymap.set('n', '<leader>ws', telescope_builtin.lsp_dynamic_workspace_symbols, { desc = 'Workspace symbols' })

vim.cmd.colorscheme('tokyonight')

vim.diagnostic.config({
  virtual_text = true,
  virtual_lines = { current_line = true },
})

vim.opt.list = true
vim.opt.listchars = {
  tab = '» ',
  nbsp = '␣',
  extends = '›',
  precedes = '‹',
  space = '·'
}
