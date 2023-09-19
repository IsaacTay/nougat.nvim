if exists('g:loaded_nougat')
  finish
endif

let g:loaded_nougat = 1

command! NougatToggle lua require('nougat').toggle()
