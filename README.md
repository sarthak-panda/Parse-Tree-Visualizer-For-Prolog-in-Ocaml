# Parse-Tree-Visualizer-For-Prolog-in-Ocaml
To run the test cases you just need to type "make" command in the terminal (assuming prequsites are installed)</br>
Further it is important to note that we assume general right associative </br>
2 + 3 - 4 * 5 / 7 * 6. the AST corresponding to the expression will assume (2+(3-(4*(5/(7*6)))))</br>
Further be sure that to add two numbers you must space seprate them from numbers as 2+3 will be tokenized to (2),(+3)</br> 
similar with -(minus) sign because they act as a sign of the numbers itself.There is no such restriction on other operators.</br>
All the results of test come in outputs folder.</br>
Currrently we do not suppourt prolog as a whole like e.g. "\+",'#',....(and the list goes on).Though we support the commonly/frequently</br>
used prolog symbols.:).</br>
Test cases were taken from https://github.com/Anniepoo/prolog-examples with few modification according to our supported symbols.</br>
Thank you.</br>
## Output Preview
![output](https://github.com/sarthak-panda/Parse-Tree-Visualizer-For-Prolog-in-Ocaml/assets/150353186/08d5e2a2-5ed4-4279-a395-9669ff1a3f25)
