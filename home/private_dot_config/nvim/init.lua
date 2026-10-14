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
}
vim.lsp.enable('clangd')
