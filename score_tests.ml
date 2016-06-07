open Score

let sample_pops = [|{x = 0; y = 0; capacity = 2}|]
let pair_of_pops = [|{x = 0; y = 0; capacity = 2};
                     {x = 0; y = 98; capacity = 3}|]
let sample_calls = [|{x = 0; y = 5; time = 0; duration = 2};
                     {x = 0; y = 5; time = 1; duration = 2};
                     {x = 0; y = -30; time = 1; duration = 3}|]
let complex_calls = [|
  {x = 0; y = 5; time = 0; duration = 2};
  {x = 0; y = 5; time = 1; duration = 2};
  {x = 0; y = -30; time = 1; duration = 3};
  {x = 10; y = 10; time = 0; duration = 10};
  {x = 10; y = 49; time = 0; duration = 100};
  {x = 0; y = 49; time = 0; duration = 100};
  {x = 0; y = 49; time = 10; duration = 10};
  {x = 0; y = 49; time = 15; duration = 10};
  {x = 0; y = 49; time = 5; duration = 10}
|]

let test_score_error pops calls connections exn msg =
  (fun () ->
     Alcotest.check_raises msg exn (fun () -> (ignore (score pops calls connections))))

let test_score pops calls connections expected =
  (fun () ->
     let score = score pops calls connections in
     Alcotest.(check int) "test score" score expected)

let score_error0 =
  let connections = [{i = 0; call = -1; pop = 0; time = 0}]
  and exn = Invalid_call {connection = 1; call = -1} in
  test_score_error sample_pops sample_calls connections exn "negative call"

let score_error1 =
  let connections = [{i = 0;call = 3; pop = 0; time = 0}]
  and exn = Invalid_call {connection = 1; call = 3} in
  test_score_error sample_pops sample_calls connections exn "non-existant call"

let score_error2 =
  let connections = [{i = 0;call = 0; pop = -1; time = 0}]
  and exn = Invalid_pop {connection = 1; pop = -1} in
  test_score_error sample_pops sample_calls connections exn "negative pop"

let score_error3 =
  let connections = [{i = 0;call = 0; pop = 1; time = 0}]
  and exn = Invalid_pop {connection = 1; pop = 1} in
  test_score_error sample_pops sample_calls connections exn "non-existant pop"

let score_error4 =
  let connections = [{i = 0;call = 0; pop = 0; time = -1}]
  and exn = Invalid_time {connection = 1; time = -1; call_time = 0} in
  test_score_error sample_pops sample_calls connections exn "negative time"

let score_error5 =
  let connections = [{i = 0;call = 1; pop = 0; time = 0}]
  and exn = Invalid_time {connection = 1; time = 0; call_time = 1} in
  test_score_error sample_pops sample_calls connections exn "invalid time"

let score_error6 =
  let connections = [{i = 0; call = 0; pop = 0; time = 0};
                     {i = 1; call = 1; pop = 0; time = 1};
                     {i = 2; call = 2; pop = 0; time = 1}]
  and exn = Pop_full {connection = 3; pop = 0; time = 1; free_time = 2} in
  test_score_error sample_pops sample_calls connections exn "pop full"

let score_error7 =
  let calls = Array.make 10 {x = 0; y = 0; time = 0; duration = 10}
  and connections = [{i = 0; call = 0; pop = 0; time = 0};
                     {i = 1; call = 1; pop = 0; time = 0};
                     {i = 2; call = 2; pop = 1; time = 0};
                     {i = 3; call = 5; pop = 1; time = 0};
                     {i = 4; call = 6; pop = 1; time = 0};
                     {i = 5; call = 7; pop = 1; time = 1}]
  and exn = (Pop_full {connection = 6; pop = 1; time = 1; free_time = 10}) in
  test_score_error pair_of_pops calls connections exn "pops full"

let score_error8 =
  let calls = Array.make 10 {x = 0; y = 0; time = 0; duration = 10}
  and connections = [{i = 0; call = 0; pop = 0; time = 0};
                     {i = 1; call = 1; pop = 0; time = 0};
                     {i = 2; call = 2; pop = 1; time = 0};
                     {i = 3; call = 5; pop = 1; time = 0};
                     {i = 4; call = 6; pop = 1; time = 2};
                     {i = 5; call = 7; pop = 1; time = 1}]
  and exn = (Pop_full {connection = 5; pop = 1; time = 2; free_time = 10}) in
  test_score_error pair_of_pops calls connections exn "pops full"

let score_error9 =
  let connections = [{i = 0; call = 0; pop = 0; time = 0};
                     {i = 1; call = 0; pop = 1; time = 0}]
  and exn = (Already_used_call {connection1 = 2; connection2 = 1; call = 0}) in
  test_score_error pair_of_pops sample_calls connections exn "duplicated calls"

let score_errors = [
  "negative call", `Quick, score_error0;
  "non-existant call", `Quick, score_error1;
  "negative pop", `Quick, score_error2;
  "non-existant pop", `Quick, score_error3;
  "negative time", `Quick, score_error4;
  "invalid time", `Quick, score_error5;
  "pop full", `Quick, score_error6;
  "pops full", `Quick, score_error7;
  "pops full", `Quick, score_error8;
  "duplicated calls", `Quick, score_error9;
]

let score_test0 =
  let connections = [] in
  test_score sample_pops sample_calls connections 0

let score_test1 =
  let connections = [{i = 0; call = 0; pop = 0; time = 0}] in
  test_score sample_pops sample_calls connections 5

let score_test2 =
  let connections = [{i = 0; call = 0; pop = 0; time = 1}] in
  test_score sample_pops sample_calls connections 4

let score_test3 =
  let connections = [{i = 0; call = 0; pop = 0; time = 41}] in
  test_score sample_pops sample_calls connections 0

let score_test4 =
  let connections = [{i = 0; call = 0; pop = 0; time = 10}] in
  test_score sample_pops sample_calls connections 4

let score_test5 =
  let connections = [{i = 0; call = 1; pop = 0; time = 11}] in
  test_score sample_pops sample_calls connections 4

let score_test6 =
  let connections = [{i = 0; call = 0; pop = 0; time = 11}] in
  test_score sample_pops sample_calls connections 3

let score_test7 =
  let connections = [{i = 0; call = 0; pop = 0; time = 1000}] in
  test_score sample_pops sample_calls connections 0

let score_test8 =
  let connections = [{i = 0; call = 0; pop = 0; time = 0};
                     {i = 1; call = 1; pop = 0; time = 1};
                     {i = 2; call = 2; pop = 0; time = 3}] in
  test_score sample_pops sample_calls connections 11

let score_test9 =
  let connections = [
    {i = 0; call = 0; pop = 0; time = 0}; (* score = 5 *)
    {i = 1; call = 1; pop = 0; time = 1}; (* score = 5 *)
    {i = 2; call = 2; pop = 0; time = 2}; (* score = 1 *)
    {i = 3; call = 3; pop = 0; time = 3}; (* score = 3 *)
    {i = 4; call = 4; pop = 0; time = 5}; (* score = 0 *)
    {i = 5; call = 5; pop = 0; time = 13}; (* score = 0 *)
    {i = 6; call = 6; pop = 0; time = 105}; (* score = 0 *)
  ] in
  test_score pair_of_pops complex_calls connections 14

let score_test10 =
  let connections = [
    {i = 0; call = 4; pop = 0; time = 0}; (* score = 0 *)
    {i = 1; call = 5; pop = 0; time = 0}; (* score = 1 *)
  ] in
  test_score sample_pops complex_calls connections 1

let score_test11 =
  let connections = [
    {i = 0; call = 5; pop = 0; time = 0}; (* score = 1 *)
    {i = 1; call = 6; pop = 0; time = 10}; (* score = 1 *)
  ] in
  test_score sample_pops complex_calls connections 2

let score_test12 =
  let connections = [
    {i = 0; call = 8; pop = 0; time = 5}; (* score = 1 *)
    {i = 1; call = 6; pop = 0; time = 10}; (* score = 1 *)
    {i = 1; call = 7; pop = 0; time = 15}; (* score = 1 *)
    {i = 1; call = 5; pop = 0; time = 20}; (* score = 0 *)
  ] in
  test_score sample_pops complex_calls connections 3

let score_test13 =
  let connections = [
    {i = 0; call = 8; pop = 0; time = 5}; (* score = 1 *)
    {i = 1; call = 6; pop = 0; time = 10}; (* score = 1 *)
    {i = 2; call = 7; pop = 0; time = 15}; (* score = 1 *)
    {i = 3; call = 5; pop = 0; time = 20}; (* score = 0 *)
  ] in
  test_score sample_pops complex_calls connections 3

let score_test14 = 
  let connections = [
    {i = 0; call = 0; pop = 0; time = 0}; (* score = 5 *)
    {i = 1; call = 1; pop = 0; time = 1}; (* score = 5 *)
    {i = 2; call = 3; pop = 0; time = 2}; (* score = 3 *)
    {i = 3; call = 8; pop = 0; time = 5}; (* score = 1 *)
    {i = 4; call = 6; pop = 0; time = 12}; (* score = 0 *)
    {i = 5; call = 7; pop = 0; time = 15}; (* score = 1 *)
  ] in
  test_score pair_of_pops complex_calls connections 15

let score_test15 = 
  let connections = [
    {i = 0; call = 0; pop = 0; time = 0}; (* score = 5 *)
    {i = 1; call = 1; pop = 0; time = 1}; (* score = 5 *)
    {i = 2; call = 3; pop = 0; time = 2}; (* score = 3 *)
    {i = 3; call = 8; pop = 1; time = 5}; (* score = 1 *)
    {i = 4; call = 6; pop = 1; time = 10}; (* score = 1 *)
    {i = 5; call = 7; pop = 1; time = 15}; (* score = 1 *)
  ] in
  test_score pair_of_pops complex_calls connections 16

let score_tests = [
  "no connections", `Quick, score_test0;
  "trivial case", `Quick, score_test1;
  "unneeded delay", `Quick, score_test2;
  "too much delay", `Quick, score_test3;
  "delay corner case", `Quick, score_test4;
  "delay corner case", `Quick, score_test5;
  "delay corner case", `Quick, score_test6;
  "delay corner case", `Quick, score_test7;
  "sample input", `Quick, score_test8;
  "complex case", `Quick, score_test9;
  "complex case", `Quick, score_test10;
  "complex case", `Quick, score_test11;
  "complex case", `Quick, score_test13;
  "complex case", `Quick, score_test13;
  "complex case", `Quick, score_test14;
  "complex case", `Quick, score_test15;
]

let () =
  Alcotest.run "score testsuite" [
    "score errors", score_errors;
    "score tests", score_tests;
  ]
