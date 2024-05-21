(* ast.ml *)

type all_types =
  | IntConst of int
  | FloatConst of float
  | StringConst of string
  | VarExp of string
  | Rule
  | Query
  | Funct of string
  | True
  | Fail
  | Cut
  | Atrate
  | Prog
  | Do_not_care
  | Tupple of all_types list
  | List of all_types list
  | NODE of all_types * all_types list

let rec to_string expr =
  match expr with
  | IntConst i -> string_of_int i
  | FloatConst f -> string_of_float f
  | StringConst s -> "\"" ^ s ^ "\""
  | VarExp v -> v
  | Rule -> "Rule(:-)"
  | Query -> "Query(?-)"
  | Prog -> "Prog"
  | Funct f -> "Function " ^ f
  | True -> "True"
  | Fail -> "Fail"
  | Do_not_care -> "DON'T_CARE"
  | Cut -> "Cut(!)"
  | Atrate -> "Atrate(@)"
  | List children ->
      let children_str = List.map to_string children |> String.concat ", " in
      "List([" ^ children_str ^ "])"
  | Tupple children ->
      let children_str = List.map to_string children |> String.concat ", " in
      "Tupple([" ^ children_str ^ "])"
  | NODE (node, children) ->
      let children_str = List.map to_string children |> String.concat ", " in
      "NODE(" ^ to_string node ^ ", [" ^ children_str ^ "])"

let rec printNTree (out_channel : out_channel) (x : all_types) (flag : bool array) (depth : int) (isLast : bool) : unit =
  for i = 1 to depth - 1 do
    if flag.(i) then
      output_string out_channel "|                    "
    else
      output_string out_channel "                     "
  done;
  let indent = if depth = 0 then "" else if flag.(depth) then "|------------------- " else "+------------------- " in
  match x with
  | IntConst n -> Printf.fprintf out_channel "%sIntConst: %d\n" indent n
  | FloatConst f -> Printf.fprintf out_channel "%sFloatConst: %f\n" indent f
  | StringConst s -> Printf.fprintf out_channel "%sStringConst: %s\n" indent s
  | VarExp v -> Printf.fprintf out_channel "%sVarExp: %s\n" indent v
  | Rule -> output_string out_channel (indent ^ "Rule(:-)\n")
  | Query -> output_string out_channel (indent ^ "Query(?-)\n")
  | Funct f -> Printf.fprintf out_channel "%sFunction: %s\n" indent f
  | True -> output_string out_channel (indent ^ "True\n")
  | Fail -> output_string out_channel (indent ^ "Fail\n")
  | Do_not_care -> output_string out_channel (indent ^ "DON'T_CARE\n")
  | Cut -> output_string out_channel (indent ^ "Cut(!)\n")
  | Atrate -> output_string out_channel (indent ^ "Atrate(@)\n")
  | Prog -> output_string out_channel (indent ^ "Prog\n")
  | List lst ->
      output_string out_channel (indent ^ "List\n");
      List.iter (fun child -> printNTree out_channel child flag (depth + 1) (child = List.hd (List.rev lst))) lst
  | Tupple lst ->
      output_string out_channel (indent ^ "Tupple\n");
      List.iter (fun child -> printNTree out_channel child flag (depth + 1) (child = List.hd (List.rev lst))) lst
  | NODE (t, lst) ->
      let node_str =
        match t with
        | IntConst n -> Printf.sprintf "%sIntConst: %d\n" indent n
        | FloatConst f -> Printf.sprintf "%sFloatConst: %f\n" indent f
        | StringConst s -> Printf.sprintf "%sStringConst: %s\n" indent s
        | VarExp v -> Printf.sprintf "%sVarExp: %s\n" indent v
        | Rule -> indent ^ "Rule(:-)\n"
        | Query -> indent ^ "Query(?-)\n"
        | Funct f -> Printf.sprintf "%sFunction: %s\n" indent f
        | True -> indent ^ "True\n"
        | Fail -> indent ^ "Fail\n"
        | Do_not_care -> indent ^ "DON'T_CARE\n"
        | Cut -> indent ^ "Cut(!)\n"
        | Atrate -> indent ^ "Atrate(@)\n"
        | Prog -> indent ^ "Prog\n"
        | List _ -> indent ^ "List\n"
        | Tupple _ -> indent ^ "Tupple\n"
        | NODE _ -> indent ^ "NODE\n"
      in
      output_string out_channel node_str;
      let print_list =
        match t with
        | List lst1 ->
            List.iter (fun child -> printNTree out_channel child flag (depth + 1) (child = List.hd (List.rev lst1))) lst1
        | _ -> ()
      in
      let print_tupple =
        match t with
        | Tupple lst2 ->
            List.iter (fun child -> printNTree out_channel child flag (depth + 1) (child = List.hd (List.rev lst2))) lst2
        | _ -> ()
      in
      List.iter (fun child -> printNTree out_channel child flag (depth + 1) (child = List.hd (List.rev lst))) lst;
      flag.(depth) <- true



let write_linear_format_ast_to_file ast file_name =
  let oc = open_out file_name in
  output_string oc (to_string ast);
  close_out oc

  let write_ast_to_file ast file_name =
    let oc = open_out file_name in
    let printTree (root : all_types) : unit =
      let nv = 10000000 in
      let flag = Array.make nv true in
      let out_channel = open_out file_name in
      printNTree oc root flag 0 false;
      close_out oc in
    printTree ast
  