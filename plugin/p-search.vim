if !exists('g:PSearch_map_n_forward')
    let g:PSearch_map_n_forward = ']]'
endif
if !exists('g:PSearch_map_v_forward')
    let g:PSearch_map_v_forward = ']]'
endif
if !exists('g:PSearch_map_n_backward')
    let g:PSearch_map_n_backward = '[['
endif
if !exists('g:PSearch_map_v_backward')
    let g:PSearch_map_v_backward = '[['
endif

execute 'nnoremap <silent>'.g:PSearch_map_n_forward.' :call <sid>FindScopedLeftParen("n")<cr>'
execute 'nnoremap <silent>'.g:PSearch_map_n_backward.' :call <sid>FindScopedLeftParen("N")<cr>'
execute 'vnoremap <silent>'.g:PSearch_map_v_forward.' <esc>:call <sid>FindScopedLeftParen("n")\|call <sid>VisualOn()<cr>'
execute 'vnoremap <silent>'.g:PSearch_map_v_backward.' <esc>:call <sid>FindScopedLeftParen("N")\|call <sid>VisualOn()<cr>'

" Uses % for matching pattern
function s:FindScopedLeftParen(direction) abort
    if !(a:direction == 'n' || a:direction == 'N')
        throw "Bad Input"
    endif

    let l:start_pos=getpos('.')
    let l:start_char = s:GetCursorChar()

    " find beg/end scope {
    if s:IsInGlobalScope(l:start_pos)
        "one before first char in buffer
        let l:beg_scope_pos=[bufnr('%'), 1, 0, 0]
        normal! G$
        let l:end_scope_pos=getpos('.')
    else
        let l:char = s:GetCursorChar()
        if l:char != '}'
            normal! [{
        else
            normal! ]}
            normal %
        end
        let l:beg_scope_pos=getpos('.')
        normal %
        let l:end_scope_pos=getpos('.')
    endif

    " check if any { in scope
    if l:start_char !~ '{\|}'
        call setpos('.', l:beg_scope_pos)
        silent! call s:IncognitoSearch('{', 'n')
        if !s:IsInScope(getpos('.'), l:beg_scope_pos, l:end_scope_pos)
            call setpos('.', l:start_pos)
            return
        endif
    endif

    " find desired {
    call setpos('.', l:start_pos)
    if a:direction == 'n'
        if l:start_char == '{'
            normal %
        endif
        silent! call s:IncognitoSearch('{', a:direction)
        let l:pattern_pos=getpos('.')

        " wrap to start of scope if necessary
        if !s:IsInScope(l:pattern_pos, l:beg_scope_pos, l:end_scope_pos)
            call setpos('.', l:beg_scope_pos)
            silent! call s:IncognitoSearch('{', 'n')
        endif
    else
        if l:start_char != '}'
            silent! call s:IncognitoSearch('}', a:direction)
        endif
        normal %
        let l:pattern_pos=getpos('.')

        " wrap to start of scope if necessary
        if !s:IsInScope(l:pattern_pos, l:beg_scope_pos, l:end_scope_pos)
            call setpos('.', l:end_scope_pos)
            silent! call s:IncognitoSearch('}', 'N')
            normal %
        endif
    endif
endfunction

function s:IncognitoSearch(pattern, motion) abort
    let l:old_search=@/
    let @/=a:pattern
    execute "silent normal! ".a:motion
    let @/=l:old_search
endfunction

function s:IsInScope(position, beg, end) abort
    return s:LessThanPos(a:beg, a:position) && s:LessThanPos(a:position, a:end)
endfunction

function s:LessThanPos(lhs,rhs) abort
    if a:lhs[1] == a:rhs[1]
        return a:lhs[2] < a:rhs[2]
    else
        return a:lhs[1] < a:rhs[1]
    endif
endfunction

function s:IsInGlobalScope(position) abort
    let l:start_pos=getpos('.')
    let l:char = s:GetCursorChar()
    if l:char != '}'
        normal! [{
    else
        normal! ]}
    endif
    let l:new_pos = getpos('.')
    call setpos('.', l:start_pos)
    return l:start_pos == l:new_pos
endfunction

function s:GetCursorChar() abort
    if v:version > 704 || v:version == 704 && has("patch1730")
        return strcharpart(getline('.'), col('.')-1, 1)
    else
        return strpart(getline('.'), col('.')-1, 1)
    endif
endfunction

function s:VisualOn() abort
    let l:start_pos=getpos('.')
    normal! gv
    call setpos('.', l:start_pos)
endfunction
