(* Validator for the optimization problem in Tuenti Challenge 2016.
     Usage: ./validator.native problem.txt solution.txt *)
open Scanf
open Core.Std
open Score

type invalid_connection = {connection: int; format: string}

exception Invalid_connection of invalid_connection

let read_limits ic = bscanf ic "%d %d\n" (fun p k -> (p, k))
let read_pop ic = bscanf ic "%d %d %d\n" (fun x y capacity -> {x; y; capacity})
let read_call ic = bscanf ic "%d %d %d %d\n" (fun x y time duration -> {x; y; time; duration})
let read_connection ic i = bscanf ic "%d %d %d\n" (fun call pop time -> {i; call; pop; time})

let read_problem path =
  let ic = Scanning.open_in path in
  let (p, k) = read_limits ic in
  let pops = Array.init p ~f:(fun _ -> read_pop ic) in
  let calls = Array.init k ~f:(fun _ -> read_call ic) in
  (pops, calls)

let read_solution path =
  let ic = Scanning.open_in path in
  let rec loop i cs =
    try
      let connection = read_connection ic i in
      loop (i + 1) (connection :: cs)
    with
      End_of_file -> cs
    | Failure(s) | Scan_failure(s) -> raise (Invalid_connection {connection = i; format = s})
    | exn -> raise exn in
  loop 1 []

let () =
  try
    let (pops, calls) = read_problem Sys.argv.(1) in
    let connections = read_solution Sys.argv.(2) in
    let score = score pops calls connections in
    print_endline (string_of_int score)
  with
    Invalid_connection {connection; format} ->
    printf "Invalid format in line %d: %s\n" connection format
  | Invalid_pop {connection; pop} ->
    printf "Invalid POP identifier in connection %d: %d\n" connection pop
  | Invalid_call {connection; call} ->
    printf "Invalid call identifier in connection %d: %d\n" connection call
  | Invalid_time {connection; time; call_time} ->
    printf "Invalid time in connection %d: specified time %d should be greater or equal than call time %d\n" connection time call_time
  | Pop_full {connection; pop; time; free_time} ->
    printf "Impossible to add connection %d at time %d: POP %d is full until %d\n" connection time pop free_time
  | Already_used_call {connection1; connection2; call} ->
    printf "Call identifier %d in connection %d already used in connection %d\n" call connection1 connection2
  | _ ->
    print_endline "Unknown error"
