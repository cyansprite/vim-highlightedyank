" highlighted-yank: Make the yanked region apparent!
" FIXME: Highlight region is incorrect when an input ^V[count]l ranges
"        multiple lines.

" variables "{{{
" null valiables
let s:null_pos = [0, 0, 0, 0]
let s:null_region = {'wise': '', 'head': copy(s:null_pos), 'tail': copy(s:null_pos), 'blockwidth': 0}

" constants
let s:maxcol = 2147483647

" SID
function! s:SID() abort
  return matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze_SID$')
endfunction
let s:SID = printf("\<SNR>%s_", s:SID())
delfunction s:SID

function! s:modify_region(region) abort "{{{
  " for multibyte characters
  if a:region.tail[2] != col([a:region.tail[1], '$']) && a:region.tail[3] == 0
    let cursor = getpos('.')
    call setpos('.', a:region.tail)
    call search('.', 'bc')
    let a:region.tail = getpos('.')
    call setpos('.', cursor)
  endif
  return a:region
endfunction
"}}}
function! s:highlight_yanked_region(region) abort "{{{
  let keyseq = ''
  let hi_group = 'HighlightedyankRegion'
  let hi_duration = s:get('highlight_duration', 1000)
  let highlight = highlightedyank#highlight#new(a:region)
  if hi_duration < 0
    call s:persist(highlight, hi_group)
  elseif hi_duration > 0
    call s:glow(highlight, hi_group, hi_duration)
  endif
endfunction
"}}}
function! s:persist(highlight, hi_group) abort  "{{{
  " highlight off: limit the number of highlighting region to one explicitly
  call highlightedyank#highlight#cancel()

  if a:highlight.show(a:hi_group)
    call a:highlight.persist()
  endif
  return ''
endfunction
"}}}
function! s:glow(highlight, hi_group, duration) abort "{{{
  " highlight off: limit the number of highlighting region to one explicitly
  " call highlightedyank#highlight#cancel()
  if a:highlight.show(a:hi_group)
    call a:highlight.quench_timer(a:duration)
  endif
  return ''
endfunction
"}}}
function! s:get(name, default) abort  "{{{
  let identifier = 'highlightedyank_' . a:name
  return get(b:, identifier, get(g:, identifier, a:default))
endfunction
"}}}

function! highlightedyank#autocmd_highlight() abort "{{{
  if v:event.operator !=# 'y' || v:event.regtype ==# ''
    return
  endif

  let view = winsaveview()
  let region = s:derive_region(v:event.regtype, v:event.regcontents)
  call s:modify_region(region)
  call s:highlight_yanked_region(region)
  call winrestview(view)
endfunction
"}}}
function! s:derive_region(regtype, regcontents) abort "{{{
  if a:regtype ==# 'v'
    let region = s:derive_region_char(a:regcontents)
  elseif a:regtype ==# 'V'
    let region = s:derive_region_line(a:regcontents)
  elseif a:regtype[0] ==# "\<C-v>"
    let width = str2nr(a:regtype[1:])
    let region = s:derive_region_block(a:regcontents, width)
  else
    let region = deepcopy(s:null_region)
  endif
  return region
endfunction
"}}}
function! s:derive_region_char(regcontents) abort "{{{
  let len = len(a:regcontents)
  let region = {}
  let region.wise = 'char'
  let region.head = getpos("'[")
  let region.tail = copy(region.head)
  if len == 0
    let region = deepcopy(s:null_region)
  elseif len == 1
    let region.tail[2] += strlen(a:regcontents[0]) - 1
  else
    let region.tail[1] += len - 1
    let region.tail[2] = strlen(a:regcontents[-1])
  endif
  return region
endfunction
"}}}
function! s:derive_region_line(regcontents) abort "{{{
  let region = {}
  let region.wise = 'line'
  let region.head = getpos("'[")
  let region.tail = getpos("']")
  return region
endfunction
"}}}
function! s:derive_region_block(regcontents, width) abort "{{{
  let len = len(a:regcontents)
  let region = deepcopy(s:null_region)
  if len > 0
    let curpos = getpos('.')
    let region.wise = 'block'
    let region.head = getpos("'[")
    call setpos('.', region.head)
    if len > 1
      execute printf('normal! %sj', len - 1)
    endif
    execute printf('normal! %s|', virtcol('.') + a:width - 1)
    let region.tail = getpos('.')
    let region.blockwidth = a:width
    if strdisplaywidth(getline('.')) < a:width
      let region.blockwidth = s:maxcol
    endif
    call setpos('.', curpos)
  endif
  return region
endfunction
"}}}

" vim:set foldmethod=marker commentstring="%s ts=2 sts=2 sw=2
