open Core.Std

type pop = { x: int; y: int; capacity: int }
type call = { x: int; y: int; time: int; duration: int }
type connection = { i: int; call: int; pop: int; time: int }

type invalid_pop = {connection: int; pop: int}
type invalid_call = {connection: int; call: int}
type invalid_time = {connection: int; time: int; call_time: int}
type pop_full = {connection: int; pop: int; time: int; free_time: int}
type used_call = {connection1: int; connection2: int; call: int}

exception Invalid_pop of invalid_pop
exception Invalid_call of invalid_call
exception Invalid_time of invalid_time
exception Pop_full of pop_full
exception Already_used_call of used_call

let score pops (calls : call array) connections =
  let queues = Array.init (Array.length pops)
      ~f:(fun i -> Heap.create ~min_size:(pops.(i).capacity) ~cmp:compare ()) in
  let connected = Array.create ~len:(Array.length calls) (-1) in
  let add_connection score connection =
    let {i; call; pop; time} = connection in
    let assert_valid_connection () = 
      if pop < 0 || pop >= Array.length pops
      then raise (Invalid_pop {connection = i; pop})
      else if call < 0 || call >= Array.length calls
      then raise (Invalid_call {connection = i; call})
      else if connected.(call) >= 0
      then raise (Already_used_call {connection1 = i; connection2 = connected.(call); call})
      else if time < calls.(call).time
      then raise (Invalid_time {connection = i; time; call_time =  calls.(call).time})
      else if (Heap.length queues.(pop)) = pops.(pop).capacity then
        begin
          let top = Heap.pop_exn queues.(pop) in
          if top > time
          then raise (Pop_full {connection = i; pop; time; free_time = top})
        end in
    assert_valid_connection ();
    connected.(call) <- i;
    Heap.add queues.(pop) (time + calls.(call).duration);
    (* Ranking by distance *)
    let call = calls.(call) in
    let pop = pops.(pop) in
    let xdiff = (Float.of_int call.x) -. (Float.of_int pop.x) in
    let ydiff = (Float.of_int call.y) -. (Float.of_int pop.y) in
    let distance = sqrt ((xdiff ** 2.) +. (ydiff ** 2.)) in
    let stars = 5 - (Float.to_int (Float.round_down (distance /. 10.))) in
    let delay = time - call.time in
    let stars = stars - (Float.to_int (Float.round_up ((Float.of_int delay) /. 10.))) in
    let stars = max stars 0 in
    score + stars in
  List.sort ~cmp:(fun (x : connection) (y : connection) -> x.time - y.time) connections
  |> List.fold_left ~init:0 ~f:add_connection;;
