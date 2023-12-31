open Ast
open Pattern

(* substitutions avoiding capture *)

let subst_ident x ex y =
  if x = y then
    (match un_annot ex with
     | E_var z -> z
     | _ -> assert false) else y

let rec subst_p x ex = function
| P_unit -> P_unit
| P_var y -> P_var (subst_ident x ex y)
| P_tuple(ps) -> P_tuple (List.map (subst_p x ex) ps)

let as_ident ex =
  match ex with
  | E_var z -> z
  | _ -> assert false (* todo: better error message *)

let rec subst_e x ex e =
  let ss = subst_e x ex in
  match e with
  | E_var y ->
      if y = x then ex else e
  | E_letIn(p,e1,e2) ->
      if pat_mem x p then E_letIn(p, ss e1, e2)
      else E_letIn(p, ss e1, ss e2)
  | E_fun(p,e1) ->
      if pat_mem x p then e else E_fun(p,ss e1)
  | E_fix(f,(p,e1)) ->
      if x = f || pat_mem x p then e else E_fix(f,(p,ss e1))
  | E_lastIn(y,e1,e2) ->
      if x = y then e else E_lastIn(y,ss e1,ss e2)
  | E_set(y,e1) ->
      let z = if x <> y then y else as_ident ex in
      E_set(z,ss e1)
  | E_static_array_get(y,e1) ->
      let z = if x <> y then y else as_ident ex in
      E_static_array_get(z,ss e1)
  | E_static_array_length(y) ->
      let z = if x <> y then y else as_ident ex in
      E_static_array_length(z)
  | E_static_array_set(y,e1,e2) ->
      let z = if x <> y then y else as_ident ex in
      E_static_array_set(z,ss e1,ss e2)
  | e -> Ast_mapper.map ss e

let rec map_subst_p (ss : (x -> e -> 'a -> 'a)) (p:p) (ep:e) (o:'a) : 'a =
    (* Format.(fprintf std_formatter "---> %a  %a\n"  Ast_pprint.pp_exp (pat2exp p) Ast_pprint.pp_exp ep); *)
  let m = bindings p ep in
  SMap.fold (fun x ex o -> ss x ex o) m o


let subst_p_e p ep o =
  map_subst_p subst_e p ep o

