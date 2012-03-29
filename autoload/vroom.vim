" Init
if exists("g:loaded_vroom") || &cp
  finish
endif
let g:loaded_vroom = 1

" Public: Run current test file, or last test run
function! vroom#RunTestFile()
  call s:RunTestFile()
endfunction

" Public: Run the nearest test in the current test file
" Assumes your test framework supports filename:line# format
function! vroom#RunNearestTest()
  call s:RunNearestTest()
endfunction

" Internal: Runs the current file as a test. Also saves the current file, so
" next time the function is called in a non-test file, it runs the last test
"
" suffix - An optional command suffix
function! s:RunTestFile(...)
  if a:0
    let command_suffix = a:1
  else
    let command_suffix = ""
  endif

  " Run the tests for the previously-marked file.
  let in_test_file = match(expand("%"), '\(.feature\|_spec.rb\|_test.rb\)$') != -1

  if in_test_file
    call s:SetTestFile()
  elseif !exists("s:test_file")
    return
  end
  call s:RunTests(s:test_file . command_suffix)
endfunction

" Internal: Runs the current or last test with the currently selected line 
" number
function! s:RunNearestTest()
  let spec_line_number = line('.')
  call s:RunTestFile(":" . spec_line_number)
endfunction

" Internal: Runs the test for a given filename
function! s:RunTests(filename)
  :w " Write the file
  call s:CheckForGemfile()
  " Run the right test for the given file
  if match(a:filename, '_spec.rb') != -1
    exec ":!" . s:bundle_exec ."rspec " . a:filename . " --no-color"
  elseif match(a:filename, '\.feature') != -1
    exec ":!" . s:bundle_exec ."script/features " . a:filename
  elseif match(a:filename, "_test.rb") != -1
    exec ":!" . s:bundle_exec ."ruby -Itest " . a:filename
  end
endfunction

" Internal: Checks for Gemfile, and sets s:bundle_exec as necessary
function! s:CheckForGemfile()
  if filereadable("Gemfile")
    let s:bundle_exec = "bundle exec "
  else
    let s:bundle_exec = ""
  endif
endfunction

" Internal: Sets s:test_file to current file
function! s:SetTestFile()
  " Set the test file that tests will be run for.
  let s:test_file=@%
endfunction