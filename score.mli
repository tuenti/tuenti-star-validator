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

val score: pop array -> call array -> connection list -> int
