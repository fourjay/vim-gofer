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
        let l:subword = l:word
        let l:glob_expression = '**/' . l:subword . '*'
        " echom 'searching for ' . l:glob_expression
        let l:files = glob( l:glob_expression, '', 1 )
        let l:files = filter (l:files , '! isdirectory(v:val)')
        if len( l:files ) > 0
            let l:candidate = l:files[0]
            " if l:candidate =~# l:word
            if l:word =~# l:candidate
                let l:found_file = l:candidate
                break
            elseif l:candidate =~# l:word . '\..*'
                let l:found_file = l:candidate
                break
            endif
        endif
    endfor
    let &wildignore = l:wildignore
    return l:found_file
endfunction
