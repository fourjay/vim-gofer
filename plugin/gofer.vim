" setup known state
if exists('did_gofer') 
      "  || &compatible 
      "  || version < 700}
    finish
endif
let g:did_gofer = '1'
let s:save_cpo = &cpoptions
set cpoptions&vim



" Return vim to users choice
let &cpoptions = s:save_cpo
