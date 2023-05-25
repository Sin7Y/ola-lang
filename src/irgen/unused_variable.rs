//  SPDX-License-Identifier: Apache-2.0

// /// Check if we should remove an assignment. The expression in the argument
// is /// the left-hand side of the assignment
// pub fn should_remove_assignment(ns: &Namespace, exp: &Expression, func:
// &Function) -> bool {     match &exp {
//         Expression::StorageVariable(_, _, contract_no, var_no, ..) => {
//             let var = &ns.contracts[*contract_no].variables[*var_no];
//             !var.read
//         }

//         Expression::Variable(_, _, var_no) => should_remove_variable(*var_no,
// func),

//         Expression::StructMember(_, _, expr, _) =>
// should_remove_assignment(ns, expr, func),

//         Expression::Subscript(_, _, _, array, _) =>
// should_remove_assignment(ns, array, func),

//         Expression::StorageLoad(_, _, expr) | Expression::Load(_, _, expr) =>
// {             should_remove_assignment(ns, expr, func)
//         }

//         _ => false,
//     }
// }

// /// Checks if we should remove a variable
// pub fn should_remove_variable(pos: usize, func: &Function) -> bool {
//     let var = &func.symtable.vars[&pos];

//     //If the variable has never been read nor assigned, we can remove it
// right     // away.
//     if !var.read && !var.assigned {
//         return true;
//     }

//     false
// }
