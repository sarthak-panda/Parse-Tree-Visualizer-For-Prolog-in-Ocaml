%{
    open Ast
%}
/* Tokens */
/* Constants */
%token <int> INT
%token <float> FLT
%token <string> STR FUN_STR
/* Variables */
%token <string> VAR
/* Symbols */
%token LPAREN     /* (  */
%token RPAREN     /* )  */
%token COMMA      /* ,  */
%token RULE       /* :- */
%token QUERY      /* ?- */
%token END        /* .  */
%token SQLBKET    /* [  */
%token SQRBKET    /* ]  */
%token PIPE       /* |  */
%token CUT
%token ARITHOP
%token FAIL
%token EOF
%token DONT_CARE
%token ATRATE
%start program
%type <Ast.all_types> clause fact rule head atom term program lst special_terminals arith_list
%type <Ast.all_types list> atom_list body clause_list term_list lst_body
%%

program:
    | p = clause_list; EOF  {NODE(Prog,p)}
clause_list:
    | c = clause; END {[c]}
    | c = clause; END; cl = clause_list {c::cl}
clause:
    | f = fact {f}
    | r = rule {r} 
    | QUERY; al=atom_list {NODE(Query,al)}
fact:
    | h = head  {NODE(Rule,[h;NODE(True,[])])}
rule:
    | h = head; RULE; b = body  {NODE(Rule,h::b)}
    | RULE; b = body  {NODE(Rule,b)}
head:
    | a = atom  {a}
body:
    | al = atom_list {al}
atom_list:
    | a = atom {[a]}
    | a = atom;COMMA; al = atom_list     {a::al}
atom:
    | arl=arith_list {arl}
lst:
    | SQLBKET; SQRBKET                                { NODE(List [],[]) }
    | SQLBKET; l = lst_body; SQRBKET                  { NODE(List l,[]) }
    | SQLBKET;t = arith_list; PIPE; tl = arith_list ; SQRBKET      { NODE(List [NODE(Funct "Head/Tail",[t; tl])],[])}      
lst_body:
    | t = arith_list                                          { [t] }
    | t = arith_list; COMMA; l = lst_body                    { t::l }
tupple:
    | LPAREN; RPAREN                                   { NODE(Tupple [],[]) }
    | LPAREN; l = tupple_body; RPAREN                  { NODE(Tupple l,[]) }
tupple_body:
    | t = arith_list                                          { [t] }
    | t = arith_list; COMMA; l = tupple_body                    { t::l }
special_terminals:
    | CUT { NODE(Cut,[]) }
    | FAIL { NODE(Fail,[]) }
    | ATRATE { NODE(Atrate,[]) }
arith_list:
    | t=term {t}
    | t=term; ARITHOP; arl=arith_list {NODE(Funct "Binary_O/P",[t;arl])}
term:
    | i = INT { NODE(IntConst i,[]) }
    | f = FLT { NODE(FloatConst f,[]) }
    | s = STR { NODE(StringConst s,[]) }
    | s1 = FUN_STR { NODE(StringConst s1,[]) }    
    | v = VAR { NODE(VarExp v,[]) } 
    | DONT_CARE {NODE(Do_not_care,[])}
    | l = lst { l } 
    | t = tupple { t }
    | s2=special_terminals {s2}
    | fn = FUN_STR; LPAREN; tl=term_list; RPAREN   {NODE(Funct fn,tl)}
term_list:
    | t=arith_list {[t]}
    | t=arith_list; COMMA; tl=term_list  {t::tl}
