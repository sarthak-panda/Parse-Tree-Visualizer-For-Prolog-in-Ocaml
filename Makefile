all:
	@menhir --base parser parser.mly > /dev/null 2>&1
	@rm -f parser.mli
	@ocamllex lexer.mll > /dev/null 2>&1
	@ocamlc -o main ast.ml parser.ml lexer.ml main.ml > /dev/null 2>&1
	@./main > /dev/null 2>&1
	@rm -f ast.cmi ast.cmo lexer.cmi lexer.cmo lexer.ml main main.cmi main.cmo parser.cmi parser.cmo parser.ml
	@find outputs -type f -name '*.txt' -exec xdg-open {} \; >/dev/null 2>&1 &
