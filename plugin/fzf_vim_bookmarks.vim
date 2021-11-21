if !has('nvim-0.5')
echohl Error
echohl clear
finish
endif

if exists('g:loaded_fzf_vim_bookmarkes') | finish | endif
let g:loaded_fzf_vim_bookmarkes = 1

" " FzfLua builtin lists
" function! s:fzflua_complete(arg,line,pos)
" let l:builtin_list = luaeval('vim.tbl_keys(require("fzf-lua"))')

" let list = [l:builtin_list]
" let l = split(a:line[:a:pos-1], '\%(\%(\%(^\|[^\\]\)\\\)\@<!\s\)\+', 1)
" let n = len(l) - index(l, 'FzfLua') - 2

" return join(list[0],"\n")
" endfunction

command! FzfVimBookmarkes lua require('vim_bookkmarks').show()
