
(* something to be printed on a 7 segment displayer *)
let default_7seg = (true,true,true,true,true,true,true,false);;


(* [counter (reset)] is instantaneous, 
   it increments its output each time it is re-executed *)
let counter (reset) =
  let inc(c) = 
    if reset then 0 else c + 1 
  in 
  reg inc last 0 ;;


(* blink a led each n clock cycles *)
let blink (n) =
  let inc c = if c = n + n then 0 else c + 1 in
  let x = (reg inc last 0) > n in
  (x,not x,not x,x,x,not x,not x,x) ;;


(** main is a reactive program (calling ocaml_vm), 
    which can be adapt to have more, or different I/Os *)
let main (button) =
  let cy = counter(button) in
  if button then (default_7seg, default_7seg) 
  else (let (stop,busy,vm_7seg) = ocaml_vm (cy,default_7seg) in
  
        (blink(10000000), vm_7seg)) ;;

