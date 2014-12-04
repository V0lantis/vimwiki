" vim:tabstop=2:shiftwidth=2:expandtab:foldmethod=marker:textwidth=79
" Vimwiki autoload plugin file
" Utility functions
" Author: Maxim Kim <habamax@gmail.com>
" Home: http://code.google.com/p/vimwiki/

function! vimwiki#u#trim(string, ...) "{{{
  let chars = ''
  if a:0 > 0
    let chars = a:1
  endif
  let res = substitute(a:string, '^[[:space:]'.chars.']\+', '', '')
  let res = substitute(res, '[[:space:]'.chars.']\+$', '', '')
  return res
endfunction "}}}

" Builtin cursor doesn't work right with unicode characters.
function! vimwiki#u#cursor(lnum, cnum) "{{{
  exe a:lnum
  exe 'normal! 0'.a:cnum.'|'
endfunction "}}}

function! vimwiki#u#is_windows() "{{{
  return has("win32") || has("win64") || has("win95") || has("win16")
endfunction "}}}

function! vimwiki#u#time(starttime) "{{{
  " measure the elapsed time and cut away miliseconds and smaller
  return matchstr(reltimestr(reltime(a:starttime)),'\d\+\(\.\d\d\)\=')
endfunction "}}}

function! vimwiki#u#count_first_sym(line) "{{{
  let first_sym = matchstr(a:line, '\S')
  return len(matchstr(a:line, first_sym.'\+'))
endfunction "}}}

function! vimwiki#u#escape(string) "{{{
  return escape(a:string, '.*[]\^$')
endfunction "}}}

" Load concrete Wiki syntax: sets regexes and templates for headers and links
function vimwiki#u#reload_regexes() "{{{
  execute 'runtime! syntax/vimwiki_'.VimwikiGet('syntax').'.vim'
endfunction "}}}

" Load syntax-specific functionality
function vimwiki#u#reload_regexes_custom() "{{{
  execute 'runtime! syntax/vimwiki_'.VimwikiGet('syntax').'_custom.vim'
endfunction "}}}
