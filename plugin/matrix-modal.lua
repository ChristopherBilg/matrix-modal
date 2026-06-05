if vim.g.loaded_matrix_modal then
  return
end
vim.g.loaded_matrix_modal = true

vim.api.nvim_create_user_command("Matrix", function()
  require("matrix-modal").start()
end, { desc = "Open the Matrix modal" })

vim.api.nvim_create_user_command("MatrixStop", function()
  require("matrix-modal").stop()
end, { desc = "Close the Matrix modal" })

vim.api.nvim_create_user_command("MatrixToggle", function()
  require("matrix-modal").toggle()
end, { desc = "Toggle the Matrix modal" })

vim.api.nvim_create_user_command("MatrixSay", function(opts)
  local text = (opts.args or ""):gsub("\\n", "\n")
  require("matrix-modal").say(text)
end, { nargs = "+", desc = "Decrypt text in the Matrix modal" })
