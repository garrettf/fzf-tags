function! fzf_tags#Find(identifier)
  let source_lines = s:source_lines(a:identifier)

  if len(source_lines) == 0
    echohl WarningMsg
    echo 'Tag not found: ' . a:identifier
    echohl None
  elseif len(source_lines) == 1
    execute 'tag' a:identifier
  else
    call fzf#run({
    \   'source': source_lines,
    \   'sink':   function('s:sink', [a:identifier]),
    \   'options': '--ansi --prompt "Tag:' . a:identifier . '> "',
    \   'down': '40%',
    \ })
  endif

endfunction

function! s:source_lines(identifier)
  let relevant_fields = map(
  \   taglist('^' . a:identifier . '$', expand('%:p')),
  \   function('s:tag_to_string')
  \ )
  return map(relevant_fields, 'join(v:val, "\t")')
endfunction

function! s:tag_to_string(index, tag_dict)
  let components = []
  if has_key(a:tag_dict, 'class')
    call add(components, s:green(a:tag_dict['class']))
  endif
  if has_key(a:tag_dict, 'filename')
    call add(components, s:magenta(a:tag_dict['filename']))
  endif
  if has_key(a:tag_dict, 'cmd')
    call add(components, s:red(a:tag_dict['cmd']))
  endif
  return components
endfunction

function! s:sink(identifier, selection)
  let parts = split(a:selection, "\t")
  let filename = parts[1]
  echom filename
  let excmd = parts[2]
  echom excmd
  execute 'silent e' filename
  execute excmd
endfunction

function! s:green(s)
  return "\033[32m" . a:s . "\033[m"
endfunction
function! s:magenta(s)
  return "\033[35m" . a:s . "\033[m"
endfunction
function! s:red(s)
  return "\033[31m" . a:s . "\033[m"
endfunction
