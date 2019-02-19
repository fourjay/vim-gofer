function! gofer#get_filtered_line_array() abort
    let l:iskeyword = &iskeyword
    set iskeyword+=.,:,/
    let l:curpos = getcurpos()
    let l:line = line('.')
    let l:non_keywords = []
    while search( '\<\(\w\|[#./"''~]\)\+\>', 'We', l:line )
        let l:synname = synIDattr(synID(line('.'),col('.'),1), 'name' )
        if l:synname !~# 'Command\|FuncName'
            call add( l:non_keywords, expand('<cword>') )
        endif
    endwhile
    call setpos( '.', l:curpos)
    let &iskeyword = l:iskeyword
    return l:non_keywords
endfunction

function! gofer#vim_glob_file(word_list)
    let l:wildignore = &wildignore
    set wildignore+=*/.git/*
    " clean out leading slash. For most of my use cases not good
    let l:word_list = map(a:word_list, "substitute( v:val, '^[/.]*', '', '')")
    let l:word_list = filter( l:word_list, 'len( v:val ) >3 ')
    " fallback list of just filenames minus extensions
    let l:short_word_list = deepcopy(l:word_list)
    call map( l:short_word_list, "fnamemodify( v:val, ':t:r')" )
    " try longer matches first, then shorter
    let l:full_list = l:word_list + l:short_word_list
    let l:found_file = ''
    for l:word in l:full_list
        let l:candidate = gofer#find_file(l:word)
        if l:candidate && l:word =~# l:candidate
                let l:found_file = l:candidate
                break
            elseif l:candidate =~# l:word . '\..*'
                let l:found_file = l:candidate
                break
        endif
    endfor
    let &wildignore = l:wildignore
    return l:found_file
endfunction

function! gofer#find_file(filename) abort
    let l:glob_expression = '**/' . a:filename . '*'
    let l:files = glob( l:glob_expression, '', 1 )
    let l:files = filter (l:files , '! isdirectory(v:val)')
    if len( l:files ) > 0
        return l:files[0]
    else
        return
    endif
endfunction

" overloaded file jump
function! gofer#jump_file() abort
    let l:save_cursor = []
    if exists('*getcurpos')
        let l:save_cursor = getcurpos()
    else
        let l:save_cursor = getpos('.')
    endif
    let l:words = joe#jump#get_line_array()

    let l:found = gofer#vim_glob_file( l:words )
    if l:found !=# ''
        echom 'loose jumping to found file ' . l:found
        execute 'edit ' . l:found
        return
    endif
    " let l:found = joe#jump#find_word_in_current_file( l:positional_order )
    " if l:found !=# ''
    "     echom 'loose jumping to found word ' . l:found
    "     normal! $
    "     call search(l:found)
    "     return
    " endif
    echom 'no match found'
    call setpos('.', l:save_cursor)
endfunction
