(* main.ml *)

open Lexer
open Parser
open Ast

let input_folder = "test_cases/"
let output_folder = "outputs/"

(* Function to create a directory if it doesn't exist *)
let create_directory_if_not_exists dir =
  if Sys.file_exists dir && Sys.is_directory dir then
    print_endline ("Directory already exists: " ^ dir)
  else (
    try
      Sys.mkdir dir 0o755;
      print_endline ("Directory created: " ^ dir)
    with
    | Sys_error msg ->
      prerr_endline ("Error creating directory: " ^ msg)
  )

let rec mkdir_p path =
  if Sys.file_exists path then () else (
    mkdir_p (Filename.dirname path);
    try
      Sys.mkdir path 0o755
    with
    | Sys_error _ ->
      ()
  )

let parse_file file_name =
  let channel = open_in file_name in
  let lexbuf = Lexing.from_channel channel in
  try
    let ast = Parser.program Lexer.token lexbuf in
    close_in channel;
    Some ast
  with
  | _ ->
    close_in channel;
    print_endline "Error occurred during parsing";
    None

let parse_and_write_file input_file output_file =
  match parse_file input_file with
  | Some ast ->
    Ast.write_ast_to_file ast output_file;
    Ast.write_linear_format_ast_to_file ast (output_file ^ "_linear_format.txt");
    print_endline ("AST generated successfully and written to " ^ output_file)
  | None ->
    print_endline ("Failed to generate AST for " ^ input_file)

    let list_files_in_folder folder =
      let rec aux acc i =
        if Sys.file_exists (folder ^ "test_" ^ string_of_int i ^ ".pl") then
          aux ((folder ^ "test_" ^ string_of_int i ^ ".pl") :: acc) (i + 1)
        else
          List.rev acc  (* Reverse the accumulated list to restore the correct order *)
      in
      aux [] 0
    

let () =
  mkdir_p output_folder;  (* Create output directory if not exists *)
  let input_files = list_files_in_folder input_folder in
  List.iteri (fun i input_file ->
    let output_file = output_folder ^ "ast_" ^ string_of_int i ^ ".txt" in
    parse_and_write_file input_file output_file
  ) input_files
