let mapleader=" "
set number

nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

colorscheme gruvbox

set hlsearch
nnoremap <CR> :noh<CR><CR>
cnoremap %% <C-R>=expand('%:h').'/'<cr>

" " Copy to clipboard
vnoremap  <leader>y  "+y
nnoremap  <leader>Y  "+yg_
nnoremap  <leader>y  "+y
nnoremap  <leader>yy  "+yy

" " Paste from clipboard
nnoremap <leader>p "+p
nnoremap <leader>P "+P
vnoremap <leader>p "+p
vnoremap <leader>P "+P

map <leader>e :edit %%
map <leader>v :view %%
map <leader>sp :split %%
map <leader>vs :vsplit %%

nnoremap <leader><leader> <c-^>

nnoremap <leader>t :Files .<CR>
nnoremap <leader>h :History<CR>
nnoremap <leader>r :Rg<CR>

set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab

set autoindent

" Maximises current split
set winwidth=125
" We have to have a winheight bigger than we want to set winminheight. But if
" we set winheight to be huge before winminheight, the winminheight set will
" fail.
set winheight=10
set winminheight=10
set winheight=50
