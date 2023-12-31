open Ast
open Ast_subst
open Pattern

(* custom symbol generator *)
module Gensym : sig val reset : unit -> unit
                    val gensym : x -> x end = struct
  
  let of_int (n:int) : x =
    "$"^string_of_int n

  let make_name (n:int) (x:x) : x =
    let x = if x = "_" then "w" else x in
    of_int n^"_"^x

  let c = ref 0

  let rename x =
    incr c;
    if String.length x > 1 && x.[0] = '$' then
      (match String.index_from_opt x 1 '_' with
      | Some i -> make_name !c (String.sub x (i+1) (String.length x - i-1))
      | None -> of_int !c)
    else make_name !c x

  let h = Hashtbl.create 10;;

  let reset () = 
    (* c := 0;*)  (* no ! *)
    Hashtbl.clear h

  let gensym x =
    if Hashtbl.mem h x then (let y = rename x in Hashtbl.add h x y; y)
    else (Hashtbl.add h x x; x)

end

open Gensym

(** [rename_pat p] rename all names in the pattern [p],
  assuming that any variable is bound several times in p *)
let rec rename_pat p =
   match p with
   | P_unit -> P_unit
   | P_var x -> P_var (gensym x)
   | P_tuple ps -> P_tuple (List.map rename_pat ps)

let rec rename_e = function
  | E_fix(f,(p,e1)) ->
      let g = gensym f in
      let pz = rename_pat p in
      let e1_ren = subst_e f (E_var g) @@
                   subst_p_e p (pat2exp pz) e1 in
      E_fix (g,(pz,rename_e e1_ren))
  | E_fun(p,e1) ->
      let pz = rename_pat p in
      E_fun (pz,rename_e (subst_p_e p (pat2exp pz) e1))
  | E_letIn(p,e1,e2) ->
      let pz = rename_pat p in
      let ez = pat2exp pz in
      E_letIn(pz, rename_e e1, rename_e @@ subst_p_e p ez e2)
  | E_lastIn(x,e1,e2) ->
      let y = gensym x in
      E_lastIn(y,rename_e e1, rename_e @@ subst_e x (E_var y) e2)
  | e -> Ast_mapper.map rename_e e

let rename_pi pi =
  Gensym.reset (); 
  let ds = List.map (fun (x,e) -> x,rename_e e) pi.ds in
  let main = rename_e pi.main in
  { pi with ds ; main }
