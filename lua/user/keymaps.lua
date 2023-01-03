-- Shorten function name
local keymap = vim.keymap.set
-- Silent keymap option
local opts = { silent = true }

--Remap space as leader key
keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "

-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",

-- Normal --
-- Better window navigation
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

-- Resize with arrows
keymap("n", "<C-Up>", ":resize -2<CR>", opts)
keymap("n", "<C-Down>", ":resize +2<CR>", opts)
keymap("n", "<C-Left>", ":vertical resize -2<CR>", opts)
keymap("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- Navigate buffers
keymap("n", "<S-l>", ":bnext<CR>", opts)
keymap("n", "<S-h>", ":bprevious<CR>", opts)

-- Clear highlights
keymap("n", "<leader>h", "<cmd>nohlsearch<CR>", opts)

-- Close buffers
keymap("n", "<S-q>", "<cmd>Bdelete!<CR>", opts)

-- Better paste
keymap("v", "p", '"_dP', opts)

-- Insert --
-- Press jk fast to enter
keymap("i", "jk", "<ESC>", opts)

-- Visual --
-- Stay in indent mode
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- Plugins --

-- NvimTree
keymap("n", "<leader>e", ":NvimTreeToggle<CR>", opts)

-- Telescope
keymap("n", "<leader>ff", ":Telescope find_files<CR>", opts)
keymap("n", "<leader>ft", ":Telescope live_grep<CR>", opts)
keymap("n", "<leader>fp", ":Telescope projects<CR>", opts)
keymap("n", "<leader>fb", ":Telescope buffers<CR>", opts)

-- Git
keymap("n", "<leader>gg", "<cmd>lua _LAZYGIT_TOGGLE()<CR>", opts)

-- Comment
keymap("n", "<leader>/", "<cmd>lua require('Comment.api').toggle.linewise.current()<CR>", opts)
keymap("x", "<leader>/", '<ESC><CMD>lua require("Comment.api").toggle.linewise(vim.fn.visualmode())<CR>')

-- DAP
keymap("n", "<leader>db", "<cmd>lua require'dap'.toggle_breakpoint()<cr>", opts)
keymap("n", "<leader>dc", "<cmd>lua require'dap'.continue()<cr>", opts)
keymap("n", "<leader>di", "<cmd>lua require'dap'.step_into()<cr>", opts)
keymap("n", "<leader>do", "<cmd>lua require'dap'.step_over()<cr>", opts)
keymap("n", "<leader>dO", "<cmd>lua require'dap'.step_out()<cr>", opts)
keymap("n", "<leader>dr", "<cmd>lua require'dap'.repl.toggle()<cr>", opts)
keymap("n", "<leader>dl", "<cmd>lua require'dap'.run_last()<cr>", opts)
keymap("n", "<leader>du", "<cmd>lua require'dapui'.toggle()<cr>", opts)
keymap("n", "<leader>dt", "<cmd>lua require'dap'.terminate()<cr>", opts)

-- Lsp
keymap("n", "<leader>lf", "<cmd>lua vim.lsp.buf.format{ async = true }<cr>", opts)

-- Julia workflow
keymap("n", "<C-j><C-o>", ":Repl julia<cr>")

vim.g.runcodecell = function (postposition)
    vim.g.sendkeys = function (keys)
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), 'n', true)
    end
    local sendkeys = vim.g.sendkeys

    local current_file = vim.api.nvim_buf_get_name(0)
    local file_length = vim.api.nvim_buf_line_count(0)
    local current_line = vim.api.nvim_win_get_cursor(0)[1]
    vim.cmd("?##")
    local prev_line = vim.api.nvim_win_get_cursor(0)[1]
    vim.cmd("/##")
    local next_line = vim.api.nvim_win_get_cursor(0)[1]
    if (current_line == prev_line) or (current_line == next_line) then
        -- ambiguous selection
        error("Ambiguous code cell, please move into a code cell")
    elseif (prev_line == 1) or (prev_line > current_line) then
        -- for cases where the code block is at the beginning
        -- and the ## delimiter is on top
        -- or the ## delimiter does not exist
        sendkeys(next_line .. "GI#=<Esc>GA=#<Esc>")
    elseif (next_line == file_length) or (next_line < current_line) then
        -- for cases where code block is at the end
        -- and the ## delimiter does not exist
        -- or the ## delimiter does not exist
        sendkeys(prev_line .. "GI=#<Esc>ggI#=<Esc>")
    elseif (current_line > prev_line) and (current_line < next_line) then
        -- for case where the code block is in the middle
        sendkeys(prev_line .. "GI=#<Esc>ggI#=<Esc>")
        sendkeys(next_line .. "GI#=<Esc>GA=#<Esc>")
    else
        print("Couldn't figure out code cell block. Line numbers:")
        print(current_line, prev_line, next_line)
    end

    sendkeys(":w<cr>")
    sendkeys(':ReplSend include("' .. current_file .. '")<cr>')
    sendkeys("u")
    if postposition == "same" then
        sendkeys(current_line .. "G")
    elseif postposition == "next" then
        print("post position")
        sendkeys(next_line .. "Gj")
    end
    sendkeys(":w<cr>")
end
keymap("n", "<M-cr>", '<cmd>lua vim.g.runcodecell("same")<cr>')
keymap("n", "<M-\\>", '<cmd>lua vim.g.runcodecell("next")<cr>')
