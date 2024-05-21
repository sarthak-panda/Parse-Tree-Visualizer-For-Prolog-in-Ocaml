{
    open Parser
}
let upper_case = ['A' - 'Z']
let underline = '_'
let lower_case = ['a' - 'z']
let digit = ['0' - '9']
let blank_space = [' ' '\t']
let end_of_line = '\n'
let string_quote = '"'
let string_quote_2 = '''
let line_comment = '%' [^ '\n'] *
let open_comment = "/*"
let close_comment = "*/"
let alphanumerical = upper_case | underline | lower_case | digit
let sign = ['+' '-']
let escape = '\\'
let any_character = [' ' - '~']
let non_escape = any_character # ['\\']
let digits = digit +
let integers = sign ? digits
let floats =
      integers '.' digits (['e' 'E'] sign ? digits) ?
    | integers ['e' 'E'] sign ? digits
let variable = (upper_case | underline) alphanumerical *
let fun_name  = lower_case | alphanumerical *
rule token = parse
    | '_'               { DONT_CARE }
    | "fail"            { FAIL          }
    | '+'|'-'|'*'|'/'|"\\=="|'>'|'<'|"=<"|'='|">="|"=:="|"=/="|"**"|"mod"|"is"|"->"|';'|"\\=" { ARITHOP }
    | [' ' '\t' '\n']   { token lexbuf }
    | eof               { EOF }
    | line_comment      { token lexbuf }
    | open_comment      { comments 1 lexbuf }
    | close_comment     { raise (Failure "unmatched closed comment") }
    | integers as n     { INT   (int_of_string n)   }
    | floats   as f     { FLT (float_of_string f) }
    | string_quote      { strings "" lexbuf }
    | string_quote_2    { strings_2 "" lexbuf }
    | variable as v     { VAR v }
    | fun_name as f     { FUN_STR f }
    | ":-"              { RULE      }
    | "?-"              { QUERY     }
    | '.'               { END    }
    | '('               { LPAREN    }
    | ')'               { RPAREN    }
    | ','               { COMMA     }
    | '['               { SQLBKET  }
    | ']'               { SQRBKET  }
    | '|'               { PIPE      }
    | '!'               { CUT         }
    | '@'               { ATRATE  }
and comments count = parse
    | open_comment      { comments (1 + count) lexbuf }
    | close_comment     { match count with
                          | 1 -> token lexbuf
                          | n -> comments (n - 1) lexbuf
                        }
    | eof               { raise (Failure "unmatched open comment") }
    | _                 { comments count lexbuf }
and strings acc = parse
    (* Consecutive strings are concatenated into a single string *)
    | string_quote blank_space * string_quote   { strings acc lexbuf }
    | string_quote                              { STR acc }
    | non_escape # ['"'] + as s                 { strings (acc ^ s) lexbuf }
    | escape                                    { escaped strings acc lexbuf }
and strings_2 acc = parse
    | string_quote_2                    { STR acc }
    | non_escape # ['''] + as a     { strings_2 (acc ^ a) lexbuf }
    | escape                        { escaped strings_2 acc lexbuf }
and escaped callback acc = parse
    | 'a'           { callback (acc ^ (String.make 1 (char_of_int   7))) lexbuf }
    | 'b'           { callback (acc ^ (String.make 1 (char_of_int   8))) lexbuf }
    | 'f'           { callback (acc ^ (String.make 1 (char_of_int  12))) lexbuf }
    | 'n'           { callback (acc ^ (String.make 1 (char_of_int  10))) lexbuf }
    | 'r'           { callback (acc ^ (String.make 1 (char_of_int  13))) lexbuf }
    | 't'           { callback (acc ^ (String.make 1 (char_of_int   9))) lexbuf }
    | 'v'           { callback (acc ^ (String.make 1 (char_of_int  11))) lexbuf }
    | 'e'           { callback (acc ^ (String.make 1 (char_of_int  27))) lexbuf }
    | 'd'           { callback (acc ^ (String.make 1 (char_of_int 127))) lexbuf }
    | escape        { callback (acc ^ "\\") lexbuf }
    | string_quote  { callback (acc ^ "\"") lexbuf }
    | end_of_line   { callback acc lexbuf }
    | 'c' (blank_space | end_of_line) *     { callback acc lexbuf }
