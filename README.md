# vim-for-latex
Make a Compile command that replicates the promised behavor of the Vimtex VimtexCompile command. 

The Vim editor must be opened in the project root directory for larger projects consisting of multiple files located in subdirectories. Otherwise the script will not know how 
to compile the project.

./document.tex
./part/chapter1.tex

If you want to edit ./part/chapter1.tex, then cwd must be ./document.tex 
To run vim navigate to ./ and run either commend:

vim . 
...and then use the editor to navigate to the file that you want to edit

or 

vim ./part/chapter1.tex
