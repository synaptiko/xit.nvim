vim.filetype.add({
	extension = {
		xit = "xit",
	},
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "xit",
	command = "setlocal shiftwidth=4 softtabstop=4 expandtab",
})
