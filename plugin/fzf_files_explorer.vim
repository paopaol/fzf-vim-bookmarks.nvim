if !has('nvim-0.5')
echohl Error
echohl clear
finish
endif

if exists('g:loaded_fzf_files_explorer') | finish | endif
let g:loaded_fzf_files_explorer = 1


command! FzfFilesExplorer lua require('files_explorer').file_explorer()
command! FzfProjects lua require('files_explorer').projects()
