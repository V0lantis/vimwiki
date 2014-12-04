" vim:tabstop=2:shiftwidth=2:expandtab:foldmethod=marker:textwidth=79
" Vimwiki autoload plugin file
" Path manipulation functions
" Author: Daniel Schemala <istjanichtzufassen@gmail.com>
" Home: http://code.google.com/p/vimwiki/


function! vimwiki#path#chomp_slash(str) "{{{
  return substitute(a:str, '[/\\]\+$', '', '')
endfunction "}}}

" collapse sections like /a/b/../c to /a/c
function! vimwiki#path#normalize(path) "{{{
  let path = a:path
  while 1
    let result = substitute(path, '/[^/]\+/\.\.', '', '')
    if result == path
      break
    endif
    let path = result
  endwhile
  return result
endfunction "}}}

function! vimwiki#path#path_norm(path) "{{{
  " /-slashes
  if a:path !~# '^scp:'
    let path = substitute(a:path, '\', '/', 'g')
    " treat multiple consecutive slashes as one path separator
    let path = substitute(path, '/\+', '/', 'g')
    " ensure that we are not fooled by a symbolic link
    return resolve(path)
  else
    return a:path
  endif
endfunction "}}}

function! vimwiki#path#is_link_to_dir(link) "{{{
  " Check if link is to a directory.
  " It should be ended with \ or /.
  if a:link =~ '.\+[/\\]$'
    return 1
  endif
  return 0
endfunction "}}}

function! vimwiki#path#abs_path_of_link(link) "{{{
  return vimwiki#path#normalize(expand("%:p:h").'/'.a:link)
endfunction "}}}

" return longest common path prefix of 2 given paths.
" '~/home/usrname/wiki', '~/home/usrname/wiki/shmiki' => '~/home/usrname/wiki'
function! vimwiki#path#path_common_pfx(path1, path2) "{{{
  let p1 = split(a:path1, '[/\\]', 1)
  let p2 = split(a:path2, '[/\\]', 1)

  let idx = 0
  let minlen = min([len(p1), len(p2)])
  while (idx < minlen) && (p1[idx] ==? p2[idx])
    let idx = idx + 1
  endwhile
  if idx == 0
    return ''
  else
    return join(p1[: idx-1], '/')
  endif
endfunction "}}}

function! vimwiki#path#wikify_path(path) "{{{
  let result = resolve(expand(a:path, ':p'))
  if vimwiki#u#is_windows()
    let result = substitute(result, '\\', '/', 'g')
  endif
  let result = vimwiki#path#chomp_slash(result)
  return result
endfunction "}}}

" Returns: the relative path from a:dir to a:file
function! vimwiki#path#relpath(dir, file) "{{{
  let result = []
  let dir = split(a:dir, '/')
  let file = split(a:file, '/')
  while (len(dir) > 0 && len(file) > 0) && dir[0] == file[0]
    call remove(dir, 0)
    call remove(file, 0)
  endwhile
  for segment in dir
    let result += ['..']
  endfor
  for segment in file
    let result += [segment]
  endfor
  return join(result, '/')
endfunction "}}}

" If the optional argument provided and nonzero,
" it will ask before creating a directory 
" Returns: 1 iff directory exists or successfully created
function! vimwiki#path#mkdir(path, ...) "{{{
  let path = expand(a:path)

  if path =~# '^scp:'
    " we can not do much, so let's pretend everything is ok
    return 1
  endif

  if isdirectory(path)
    return 1
  else
    if !exists("*mkdir")
      return 0
    endif

    let path = vimwiki#path#chomp_slash(path)
    if vimwiki#u#is_windows() && !empty(g:vimwiki_w32_dir_enc)
      let path = iconv(path, &enc, g:vimwiki_w32_dir_enc)
    endif

    if a:0 && a:1 && tolower(input("Vimwiki: Make new directory: ".path."\n [Y]es/[n]o? ")) !~ "^y"
      return 0
    endif

    call mkdir(path, "p")
    return 1
  endif
endfunction " }}}
