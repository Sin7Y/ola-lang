// SPDX-License-Identifier: Apache-2.0

use crate::sema::{ast::*, symtable::Symtable};
use ola_parser::{program, program::Loc};
use std::fmt::Write;

struct Node {
    name: String,
    labels: Vec<String>,
}

impl Node {
    fn new(name: &str, labels: Vec<String>) -> Self {
        Node {
            name: name.to_owned(),
            labels,
        }
    }
}

struct Edge {
    from: usize,
    to: usize,
    label: Option<String>,
}

struct Dot {
    filename: String,
    nodes: Vec<Node>,
    edges: Vec<Edge>,
}

impl Dot {
    fn write(&self) -> String {
        let mut result = format!("strict digraph \"{}\" {{\n", self.filename);

        for node in &self.nodes {
            if !node.labels.is_empty() {
                writeln!(
                    result,
                    "\t{} [label=\"{}\"]",
                    node.name,
                    node.labels.join("\\n")
                )
                .unwrap();
            }
        }

        for edge in &self.edges {
            if let Some(label) = &edge.label {
                writeln!(
                    result,
                    "\t{} -> {} [label=\"{}\"]",
                    self.nodes[edge.from].name, self.nodes[edge.to].name, label
                )
                .unwrap();
            } else {
                writeln!(
                    result,
                    "\t{} -> {}",
                    self.nodes[edge.from].name, self.nodes[edge.to].name
                )
                .unwrap();
            }
        }

        result.push_str("}\n");

        result
    }

    fn add_node(
        &mut self,
        mut node: Node,
        parent: Option<usize>,
        parent_rel: Option<String>,
    ) -> usize {
        let no = self.nodes.len();

        debug_assert!(
            !node.name.chars().any(|c| c.is_whitespace()),
            "{} contains whitespace",
            node.name
        );

        if node.name.is_empty() || node.name == "node" {
            node.name = format!("node_{}", no);
        } else {
            while self.nodes.iter().any(|n| n.name == node.name) {
                node.name = format!("{}_{}", node.name, no);
            }
        }

        self.nodes.push(node);

        if let Some(parent) = parent {
            self.edges.push(Edge {
                from: parent,
                to: no,
                label: parent_rel,
            })
        }

        no
    }

    fn add_function(&mut self, func: &Function, ns: &Namespace, parent: usize) {
        let mut labels = vec![format!("{}", func.name), ns.loc_to_string(&func.loc)];

        if let Some(contract) = func.contract_no {
            labels.insert(1, format!("contract: {}", ns.contracts[contract].name));
        }

        labels.push(format!("signature {}", func.signature));

        if let Some(selector) = &func.selector {
            labels.push(format!("selector {}", hex::encode(selector)));
        }

        let func_node = self.add_node(
            Node::new(&func.name, labels),
            Some(parent),
            Some(format!("fn")),
        );

        // parameters
        if !func.params.is_empty() {
            let mut labels = vec![String::from("parameters")];

            for param in &*func.params {
                labels.push(format!(
                    "{} {}",
                    param.ty.to_string(ns),
                    param.name_as_str()
                ));
            }

            self.add_node(
                Node::new("parameters", labels),
                Some(func_node),
                Some(String::from("parameters")),
            );
        }

        // returns
        if !func.returns.is_empty() {
            let mut labels = vec![String::from("returns")];

            for param in &*func.returns {
                labels.push(format!(
                    "{} {}",
                    param.ty.to_string(ns),
                    param.name_as_str()
                ));
            }

            self.add_node(
                Node::new("returns", labels),
                Some(func_node),
                Some(String::from("returns")),
            );
        }

        // body
        self.add_statement(&func.body, func, ns, func_node, String::from("body"));
    }

    fn add_expression(
        &mut self,
        expr: &Expression,
        func: Option<&Function>,
        ns: &Namespace,
        parent: usize,
        parent_rel: String,
    ) {
        match expr {
            Expression::BoolLiteral(loc, val) => {
                let labels = vec![
                    format!("bool literal: {}", if *val { "true" } else { "false" }),
                    ns.loc_to_string(loc),
                ];

                self.add_node(
                    Node::new("bool_literal", labels),
                    Some(parent),
                    Some(parent_rel),
                );
            }

            Expression::NumberLiteral(loc, ty, val) => {
                let labels = vec![
                    format!("{} literal: {}", ty.to_string(ns), val),
                    ns.loc_to_string(loc),
                ];

                self.add_node(
                    Node::new("number_literal", labels),
                    Some(parent),
                    Some(parent_rel),
                );
            }

            Expression::StructLiteral(loc, ty, args) => {
                let labels = vec![
                    format!("struct literal: {}", ty.to_string(ns)),
                    ns.loc_to_string(loc),
                ];

                let node = self.add_node(
                    Node::new("struct_literal", labels),
                    Some(parent),
                    Some(parent_rel),
                );

                for (no, arg) in args.iter().enumerate() {
                    self.add_expression(arg, func, ns, node, format!("arg #{}", no));
                }
            }
            Expression::ArrayLiteral(loc, ty, _, args) => {
                let labels = vec![
                    format!("array literal: {}", ty.to_string(ns)),
                    ns.loc_to_string(loc),
                ];

                let node = self.add_node(
                    Node::new("array_literal", labels),
                    Some(parent),
                    Some(parent_rel),
                );

                for (no, arg) in args.iter().enumerate() {
                    self.add_expression(arg, func, ns, node, format!("arg #{}", no));
                }
            }
            Expression::ConstArrayLiteral(loc, ty, _, args) => {
                let labels = vec![
                    format!("array literal: {}", ty.to_string(ns)),
                    ns.loc_to_string(loc),
                ];

                let node = self.add_node(
                    Node::new("array_literal", labels),
                    Some(parent),
                    Some(parent_rel),
                );

                for (no, arg) in args.iter().enumerate() {
                    self.add_expression(arg, func, ns, node, format!("arg #{}", no));
                }
            }
            Expression::ZeroExt { loc, to, expr } => {
                let node = self.add_node(
                    Node::new(
                        "zero_ext",
                        vec![
                            format!("zero extend {}", to.to_string(ns)),
                            ns.loc_to_string(loc),
                        ],
                    ),
                    Some(parent),
                    Some(parent_rel),
                );

                self.add_expression(expr, func, ns, node, String::from("expr"));
            }
            Expression::Trunc { loc, to, expr } => {
                let node = self.add_node(
                    Node::new(
                        "trunc",
                        vec![
                            format!("truncate {}", to.to_string(ns)),
                            ns.loc_to_string(loc),
                        ],
                    ),
                    Some(parent),
                    Some(parent_rel),
                );

                self.add_expression(expr, func, ns, node, String::from("expr"));
            }
            Expression::Cast { loc, to, expr } => {
                let node = self.add_node(
                    Node::new(
                        "cast",
                        vec![format!("cast {}", to.to_string(ns)), ns.loc_to_string(loc)],
                    ),
                    Some(parent),
                    Some(parent_rel),
                );

                self.add_expression(expr, func, ns, node, String::from("expr"));
            }
            Expression::Add(loc, ty, left, right) => {
                let mut labels = vec![String::from("add"), ty.to_string(ns), ns.loc_to_string(loc)];
                let node = self.add_node(Node::new("add", labels), Some(parent), Some(parent_rel));

                self.add_expression(left, func, ns, node, String::from("left"));
                self.add_expression(right, func, ns, node, String::from("right"));
            }
            Expression::Subtract(loc, ty, left, right) => {
                let mut labels = vec![
                    String::from("subtract"),
                    ty.to_string(ns),
                    ns.loc_to_string(loc),
                ];
                let node = self.add_node(
                    Node::new("subtract", labels),
                    Some(parent),
                    Some(parent_rel),
                );

                self.add_expression(left, func, ns, node, String::from("left"));
                self.add_expression(right, func, ns, node, String::from("right"));
            }
            Expression::Multiply(loc, ty, left, right) => {
                let mut labels = vec![
                    String::from("multiply"),
                    ty.to_string(ns),
                    ns.loc_to_string(loc),
                ];
                let node = self.add_node(
                    Node::new("multiply", labels),
                    Some(parent),
                    Some(parent_rel),
                );

                self.add_expression(left, func, ns, node, String::from("left"));
                self.add_expression(right, func, ns, node, String::from("right"));
            }
            Expression::Divide(loc, ty, left, right) => {
                let labels = vec![
                    String::from("divide"),
                    ty.to_string(ns),
                    ns.loc_to_string(loc),
                ];
                let node =
                    self.add_node(Node::new("divide", labels), Some(parent), Some(parent_rel));

                self.add_expression(left, func, ns, node, String::from("left"));
                self.add_expression(right, func, ns, node, String::from("right"));
            }
            Expression::Modulo(loc, ty, left, right) => {
                let labels = vec![
                    String::from("modulo"),
                    ty.to_string(ns),
                    ns.loc_to_string(loc),
                ];
                let node =
                    self.add_node(Node::new("modulo", labels), Some(parent), Some(parent_rel));

                self.add_expression(left, func, ns, node, String::from("left"));
                self.add_expression(right, func, ns, node, String::from("right"));
            }
            Expression::Power(loc, ty, left, right) => {
                let mut labels = vec![
                    String::from("power"),
                    ty.to_string(ns),
                    ns.loc_to_string(loc),
                ];
                let node =
                    self.add_node(Node::new("power", labels), Some(parent), Some(parent_rel));

                self.add_expression(left, func, ns, node, String::from("left"));
                self.add_expression(right, func, ns, node, String::from("right"));
            }
            Expression::BitwiseOr(loc, ty, left, right) => {
                let labels = vec![
                    String::from("bitwise or"),
                    ty.to_string(ns),
                    ns.loc_to_string(loc),
                ];
                let node = self.add_node(
                    Node::new("bitwise_or", labels),
                    Some(parent),
                    Some(parent_rel),
                );

                self.add_expression(left, func, ns, node, String::from("left"));
                self.add_expression(right, func, ns, node, String::from("right"));
            }
            Expression::BitwiseAnd(loc, ty, left, right) => {
                let labels = vec![
                    String::from("bitwise and"),
                    ty.to_string(ns),
                    ns.loc_to_string(loc),
                ];
                let node = self.add_node(
                    Node::new("bitwise_and", labels),
                    Some(parent),
                    Some(parent_rel),
                );

                self.add_expression(left, func, ns, node, String::from("left"));
                self.add_expression(right, func, ns, node, String::from("right"));
            }
            Expression::BitwiseXor(loc, ty, left, right) => {
                let labels = vec![
                    String::from("bitwise xor"),
                    ty.to_string(ns),
                    ns.loc_to_string(loc),
                ];
                let node = self.add_node(
                    Node::new("bitwise_xor", labels),
                    Some(parent),
                    Some(parent_rel),
                );

                self.add_expression(left, func, ns, node, String::from("left"));
                self.add_expression(right, func, ns, node, String::from("right"));
            }
            Expression::ShiftLeft(loc, ty, left, right) => {
                let labels = vec![
                    String::from("shift left"),
                    ty.to_string(ns),
                    ns.loc_to_string(loc),
                ];
                let node = self.add_node(
                    Node::new("shift_left", labels),
                    Some(parent),
                    Some(parent_rel),
                );

                self.add_expression(left, func, ns, node, String::from("left"));
                self.add_expression(right, func, ns, node, String::from("right"));
            }
            Expression::ShiftRight(loc, ty, left, right) => {
                let labels = vec![
                    String::from("shift right"),
                    ty.to_string(ns),
                    ns.loc_to_string(loc),
                ];
                let node = self.add_node(
                    Node::new("shift_right", labels),
                    Some(parent),
                    Some(parent_rel),
                );

                self.add_expression(left, func, ns, node, String::from("left"));
                self.add_expression(right, func, ns, node, String::from("right"));
            }
            Expression::ConstantVariable(loc, ty, contract, var_no) => {
                self.add_constant_variable(loc, ty, contract, var_no, parent, parent_rel, ns);
            }
            Expression::Variable(loc, ty, var_no) => {
                let labels = vec![
                    format!("variable: {}", func.unwrap().symtable.vars[var_no].id.name),
                    ty.to_string(ns),
                    ns.loc_to_string(loc),
                ];

                self.add_node(
                    Node::new("variable", labels),
                    Some(parent),
                    Some(parent_rel),
                );
            }

            Expression::Increment(loc, ty, expr) => {
                let mut labels = vec![
                    String::from("pre increment"),
                    ty.to_string(ns),
                    ns.loc_to_string(loc),
                ];
                let node = self.add_node(
                    Node::new("pre_increment", labels),
                    Some(parent),
                    Some(parent_rel),
                );

                self.add_expression(expr, func, ns, node, String::from("expr"));
            }
            Expression::Decrement(loc, ty, expr) => {
                let mut labels = vec![
                    String::from("pre decrement"),
                    ty.to_string(ns),
                    ns.loc_to_string(loc),
                ];
                let node = self.add_node(
                    Node::new("pre_decrement", labels),
                    Some(parent),
                    Some(parent_rel),
                );

                self.add_expression(expr, func, ns, node, String::from("expr"));
            }

            Expression::Assign(loc, ty, left, right) => {
                let labels = vec![
                    String::from("assign"),
                    ty.to_string(ns),
                    ns.loc_to_string(loc),
                ];
                let node =
                    self.add_node(Node::new("assign", labels), Some(parent), Some(parent_rel));

                self.add_expression(left, func, ns, node, String::from("left"));
                self.add_expression(right, func, ns, node, String::from("right"));
            }

            Expression::More(loc, left, right) => {
                let labels = vec![String::from("more"), ns.loc_to_string(loc)];
                let node = self.add_node(Node::new("more", labels), Some(parent), Some(parent_rel));

                self.add_expression(left, func, ns, node, String::from("left"));
                self.add_expression(right, func, ns, node, String::from("right"));
            }
            Expression::Less(loc, left, right) => {
                let labels = vec![String::from("less"), ns.loc_to_string(loc)];
                let node = self.add_node(Node::new("less", labels), Some(parent), Some(parent_rel));

                self.add_expression(left, func, ns, node, String::from("left"));
                self.add_expression(right, func, ns, node, String::from("right"));
            }
            Expression::MoreEqual(loc, left, right) => {
                let labels = vec![String::from("more equal"), ns.loc_to_string(loc)];
                let node = self.add_node(
                    Node::new("more_equal", labels),
                    Some(parent),
                    Some(parent_rel),
                );

                self.add_expression(left, func, ns, node, String::from("left"));
                self.add_expression(right, func, ns, node, String::from("right"));
            }
            Expression::LessEqual(loc, left, right) => {
                let labels = vec![String::from("less equal"), ns.loc_to_string(loc)];
                let node = self.add_node(
                    Node::new("less_equal", labels),
                    Some(parent),
                    Some(parent_rel),
                );

                self.add_expression(left, func, ns, node, String::from("left"));
                self.add_expression(right, func, ns, node, String::from("right"));
            }
            Expression::Equal(loc, left, right) => {
                let labels = vec![String::from("equal"), ns.loc_to_string(loc)];
                let node =
                    self.add_node(Node::new("equal", labels), Some(parent), Some(parent_rel));

                self.add_expression(left, func, ns, node, String::from("left"));
                self.add_expression(right, func, ns, node, String::from("right"));
            }
            Expression::NotEqual(loc, left, right) => {
                let labels = vec![String::from("not equal"), ns.loc_to_string(loc)];
                let node = self.add_node(
                    Node::new("not_qual", labels),
                    Some(parent),
                    Some(parent_rel),
                );

                self.add_expression(left, func, ns, node, String::from("left"));
                self.add_expression(right, func, ns, node, String::from("right"));
            }

            Expression::Not(loc, expr) => {
                let node = self.add_node(
                    Node::new("not", vec![String::from("not"), ns.loc_to_string(loc)]),
                    Some(parent),
                    Some(parent_rel),
                );

                self.add_expression(expr, func, ns, node, String::from("expr"));
            }
            Expression::Complement(loc, ty, expr) => {
                let node = self.add_node(
                    Node::new(
                        "complement",
                        vec![
                            format!("complement {}", ty.to_string(ns)),
                            ns.loc_to_string(loc),
                        ],
                    ),
                    Some(parent),
                    Some(parent_rel),
                );

                self.add_expression(expr, func, ns, node, String::from("expr"));
            }
            Expression::UnaryMinus(loc, ty, expr) => {
                let node = self.add_node(
                    Node::new(
                        "unary_minus",
                        vec![
                            format!("unary minus {}", ty.to_string(ns)),
                            ns.loc_to_string(loc),
                        ],
                    ),
                    Some(parent),
                    Some(parent_rel),
                );

                self.add_expression(expr, func, ns, node, String::from("expr"));
            }

            Expression::ConditionalOperator(loc, ty, cond, left, right) => {
                let node = self.add_node(
                    Node::new(
                        "conditional",
                        vec![
                            format!("conditional operator {}", ty.to_string(ns)),
                            ns.loc_to_string(loc),
                        ],
                    ),
                    Some(parent),
                    Some(parent_rel),
                );

                self.add_expression(cond, func, ns, node, String::from("cond"));
                self.add_expression(left, func, ns, node, String::from("left"));
                self.add_expression(right, func, ns, node, String::from("right"));
            }
            Expression::Subscript(loc, _, ty, array, index) => {
                let node = self.add_node(
                    Node::new(
                        "subscript",
                        vec![
                            format!("subscript {}", ty.to_string(ns)),
                            ns.loc_to_string(loc),
                        ],
                    ),
                    Some(parent),
                    Some(parent_rel),
                );

                self.add_expression(array, func, ns, node, String::from("array"));
                self.add_expression(index, func, ns, node, String::from("index"));
            }
            Expression::StructMember(loc, ty, var, member) => {
                let node = self.add_node(
                    Node::new(
                        "structmember",
                        vec![
                            format!("struct member #{} {}", member, ty.to_string(ns)),
                            ns.loc_to_string(loc),
                        ],
                    ),
                    Some(parent),
                    Some(parent_rel),
                );

                self.add_expression(var, func, ns, node, String::from("var"));
            }

            Expression::StorageArrayLength {
                loc,
                ty,
                array,
                elem_ty,
            } => {
                let node = self.add_node(
                    Node::new(
                        "array_length",
                        vec![
                            format!("array length {}", ty.to_string(ns)),
                            format!("element {}", elem_ty.to_string(ns)),
                            ns.loc_to_string(loc),
                        ],
                    ),
                    Some(parent),
                    Some(parent_rel),
                );

                self.add_expression(array, func, ns, node, String::from("array"));
            }

            Expression::Or(loc, left, right) => {
                let labels = vec![String::from("logical or"), ns.loc_to_string(loc)];
                let node = self.add_node(
                    Node::new("logical_or", labels),
                    Some(parent),
                    Some(parent_rel),
                );

                self.add_expression(left, func, ns, node, String::from("left"));
                self.add_expression(right, func, ns, node, String::from("right"));
            }
            Expression::And(loc, left, right) => {
                let labels = vec![String::from("logical and"), ns.loc_to_string(loc)];
                let node = self.add_node(
                    Node::new("logical_and", labels),
                    Some(parent),
                    Some(parent_rel),
                );

                self.add_expression(left, func, ns, node, String::from("left"));
                self.add_expression(right, func, ns, node, String::from("right"));
            }

            Expression::Function {
                loc,
                ty,
                function_no,
                signature,
            } => {
                let mut labels = vec![ty.to_string(ns), ns.loc_to_string(loc)];

                let func = &ns.functions[*function_no];

                if let Some(contract_no) = func.contract_no {
                    labels.insert(
                        1,
                        format!("{}.{}", ns.contracts[contract_no].name, func.name),
                    )
                } else {
                    labels.insert(1, format!("free function {}", func.name))
                }

                if let Some(signature) = signature {
                    labels.insert(1, format!("signature {}", signature))
                }

                self.add_node(
                    Node::new("internal_function", labels),
                    Some(parent),
                    Some(parent_rel),
                );
            }
            Expression::FunctionCall {
                loc,
                function,
                args,
                ..
            } => {
                let labels = vec![
                    String::from("call internal function"),
                    ns.loc_to_string(loc),
                ];

                let node = self.add_node(
                    Node::new("call_internal_function", labels),
                    Some(parent),
                    Some(parent_rel),
                );

                self.add_expression(function, func, ns, node, String::from("function"));

                for (no, arg) in args.iter().enumerate() {
                    self.add_expression(arg, func, ns, node, format!("arg #{}", no));
                }
            }

            Expression::Builtin(loc, _, builtin, args) => {
                let labels = vec![format!("builtin {:?}", builtin), ns.loc_to_string(loc)];

                let node = self.add_node(
                    Node::new("builtins", labels),
                    Some(parent),
                    Some(parent_rel),
                );

                for (no, arg) in args.iter().enumerate() {
                    self.add_expression(arg, func, ns, node, format!("arg #{}", no));
                }
            }

            Expression::List(loc, list) => {
                let labels = vec![String::from("list"), ns.loc_to_string(loc)];

                let node = self.add_node(Node::new("list", labels), Some(parent), Some(parent_rel));

                for (no, expr) in list.iter().enumerate() {
                    self.add_expression(expr, func, ns, node, format!("entry #{}", no));
                }
            }
        }
    }

    fn add_statement(
        &mut self,
        stmts: &[Statement],
        func: &Function,
        ns: &Namespace,
        parent: usize,
        parent_rel: String,
    ) {
        let mut parent = parent;
        let mut parent_rel = parent_rel;

        for stmt in stmts {
            match stmt {
                Statement::Block {
                    loc,
                    unchecked,
                    statements,
                } => {
                    let mut labels = vec![String::from("block"), ns.loc_to_string(loc)];

                    if *unchecked {
                        labels.push(String::from("unchecked"));
                    }

                    parent =
                        self.add_node(Node::new("block", labels), Some(parent), Some(parent_rel));

                    self.add_statement(statements, func, ns, parent, String::from("statements"));
                }
                Statement::VariableDecl(loc, _, param, init) => {
                    let labels = vec![
                        format!(
                            "variable decl {} {}",
                            param.ty.to_string(ns),
                            param.name_as_str()
                        ),
                        ns.loc_to_string(loc),
                    ];

                    parent = self.add_node(
                        Node::new("var_decl", labels),
                        Some(parent),
                        Some(parent_rel),
                    );

                    if let Some(init) = init {
                        self.add_expression(init, Some(func), ns, parent, String::from("init"));
                    }
                }
                Statement::If(loc, _, cond, then, else_) => {
                    let labels = vec![String::from("if"), ns.loc_to_string(loc)];

                    parent = self.add_node(Node::new("if", labels), Some(parent), Some(parent_rel));

                    self.add_expression(cond, Some(func), ns, parent, String::from("cond"));
                    self.add_statement(then, func, ns, parent, String::from("then"));
                    self.add_statement(else_, func, ns, parent, String::from("else"));
                }

                Statement::For {
                    loc,
                    init,
                    cond,
                    next,
                    body,
                    ..
                } => {
                    let labels = vec![String::from("for"), ns.loc_to_string(loc)];

                    parent =
                        self.add_node(Node::new("for", labels), Some(parent), Some(parent_rel));

                    self.add_statement(init, func, ns, parent, String::from("init"));
                    if let Some(cond) = cond {
                        self.add_expression(cond, Some(func), ns, parent, String::from("cond"));
                    }
                    self.add_statement(next, func, ns, parent, String::from("next"));
                    self.add_statement(body, func, ns, parent, String::from("body"));
                }

                Statement::Expression(loc, _, expr) => {
                    let labels = vec![String::from("expression"), ns.loc_to_string(loc)];

                    parent =
                        self.add_node(Node::new("expr", labels), Some(parent), Some(parent_rel));

                    self.add_expression(expr, Some(func), ns, parent, String::from("expr"));
                }

                Statement::Continue(loc) => {
                    let labels = vec![String::from("continue"), ns.loc_to_string(loc)];

                    parent = self.add_node(
                        Node::new("continue", labels),
                        Some(parent),
                        Some(parent_rel),
                    );
                }
                Statement::Break(loc) => {
                    let labels = vec![String::from("break"), ns.loc_to_string(loc)];

                    parent =
                        self.add_node(Node::new("break", labels), Some(parent), Some(parent_rel));
                }
                Statement::Return(loc, expr) => {
                    let labels = vec![String::from("return"), ns.loc_to_string(loc)];

                    parent =
                        self.add_node(Node::new("return", labels), Some(parent), Some(parent_rel));

                    if let Some(expr) = expr {
                        self.add_expression(expr, Some(func), ns, parent, String::from("expr"));
                    }
                }

                Statement::Underscore(loc) => {
                    let labels = vec![String::from("undersore"), ns.loc_to_string(loc)];

                    parent = self.add_node(
                        Node::new("underscore", labels),
                        Some(parent),
                        Some(parent_rel),
                    );
                }
            }
            parent_rel = String::from("next");
        }
    }

    fn add_constant_variable(
        &mut self,
        loc: &Loc,
        ty: &Type,
        contract: &Option<usize>,
        var_no: &usize,
        parent: usize,
        parent_rel: String,
        ns: &Namespace,
    ) {
        let mut labels = vec![
            String::from("constant variable"),
            ty.to_string(ns),
            ns.loc_to_string(loc),
        ];

        if let Some(contract) = contract {
            labels.insert(
                1,
                format!(
                    "{}.{}",
                    ns.contracts[*contract].name, ns.contracts[*contract].variables[*var_no].name
                ),
            );
        } else {
            labels.insert(1, ns.constants[*var_no].name.to_string());
        }

        self.add_node(
            Node::new("constant", labels),
            Some(parent),
            Some(parent_rel),
        );
    }

    fn add_storage_variable(
        &mut self,
        loc: &Loc,
        ty: &Type,
        contract: &usize,
        var_no: &usize,
        parent: usize,
        parent_rel: String,
        ns: &Namespace,
    ) {
        let labels = vec![
            String::from("storage variable"),
            format!(
                "{}.{}",
                ns.contracts[*contract].name, ns.contracts[*contract].variables[*var_no].name
            ),
            ty.to_string(ns),
            ns.loc_to_string(loc),
        ];

        self.add_node(
            Node::new("storage_var", labels),
            Some(parent),
            Some(parent_rel),
        );
    }
}

impl Namespace {
    pub fn dotgraphviz(&self) -> String {
        let mut dot = Dot {
            filename: format!("{}", self.files[self.top_file_no()].path.display()),
            nodes: Vec::new(),
            edges: Vec::new(),
        };

        // enums
        if !self.enums.is_empty() {
            let enums = dot.add_node(Node::new("enums", Vec::new()), None, None);

            for decl in &self.enums {
                let mut labels = decl
                    .values
                    .iter()
                    .map(|(name, _)| format!("value: {}", name))
                    .collect::<Vec<String>>();

                labels.insert(0, self.loc_to_string(&decl.loc));
                if let Some(contract) = &decl.contract {
                    labels.insert(0, format!("contract: {}", contract));
                }
                labels.insert(0, format!("name: {}", decl.name));

                let e = Node::new(&decl.name, labels);

                let node = dot.add_node(e, Some(enums), None);
            }
        }

        // structs
        if !self.structs.is_empty() {
            let structs = dot.add_node(Node::new("structs", Vec::new()), None, None);

            for decl in &self.structs {
                if let program::Loc::File(..) = &decl.loc {
                    let mut labels =
                        vec![format!("name:{}", decl.name), self.loc_to_string(&decl.loc)];

                    if let Some(contract) = &decl.contract {
                        labels.insert(1, format!("contract: {}", contract));
                    }

                    for field in &decl.fields {
                        labels.push(format!(
                            "field name:{} ty:{}",
                            field.name_as_str(),
                            field.ty.to_string(self)
                        ));
                    }

                    let e = Node::new(&decl.name, labels);

                    let node = dot.add_node(e, Some(structs), None);
                }
            }
        }

        // user types
        if self
            .user_types
            .iter()
            .any(|t| t.loc != program::Loc::Builtin)
        {
            let types = dot.add_node(Node::new("types", Vec::new()), None, None);

            for decl in self
                .user_types
                .iter()
                .filter(|t| t.loc != program::Loc::Builtin)
            {
                let mut labels = vec![
                    format!("name:{} ty:{}", decl.name, decl.ty.to_string(self)),
                    self.loc_to_string(&decl.loc),
                ];

                if let Some(contract) = &decl.contract {
                    labels.insert(1, format!("contract: {}", contract));
                }

                let e = Node::new(&decl.name, labels);

                let node = dot.add_node(e, Some(types), None);
            }
        }

        // free functions
        if self
            .functions
            .iter()
            .any(|func| func.contract_no.is_none() && func.loc != program::Loc::Builtin)
        {
            let functions = dot.add_node(Node::new("free_functions", Vec::new()), None, None);

            for func in &self.functions {
                if func.contract_no.is_none() && func.loc != program::Loc::Builtin {
                    dot.add_function(func, self, functions);
                }
            }
        }

        let contracts = dot.add_node(Node::new("contracts", Vec::new()), None, None);

        // contracts
        for c in &self.contracts {
            let contract = dot.add_node(
                Node::new(
                    "contract",
                    vec![format!("contract {}", c.name), self.loc_to_string(&c.loc)],
                ),
                Some(contracts),
                None,
            );

            for var in &c.variables {
                let mut labels = vec![
                    format!("variable {}", var.name),
                    self.loc_to_string(&var.loc),
                ];

                if var.constant {
                    labels.insert(2, String::from("constant"));
                }

                let node = dot.add_node(
                    Node::new("var", labels),
                    Some(contract),
                    Some(String::from("variable")),
                );

                if let Some(initializer) = &var.initializer {
                    dot.add_expression(initializer, None, self, node, String::from("initializer"));
                }
            }

            for func in &c.functions {
                dot.add_function(&self.functions[*func], self, contract);
            }
        }

        // diagnostics
        if !self.diagnostics.is_empty() {
            let diagnostics = dot.add_node(Node::new("diagnostics", Vec::new()), None, None);

            for diag in self.diagnostics.iter() {
                let mut labels = vec![diag.message.to_string(), format!("level {:?}", diag.level)];

                labels.push(self.loc_to_string(&diag.loc));

                let node = dot.add_node(
                    Node::new("diagnostic", labels),
                    Some(diagnostics),
                    Some(format!("{:?}", diag.level)),
                );

                for note in &diag.notes {
                    dot.add_node(
                        Node::new(
                            "note",
                            vec![note.message.to_string(), self.loc_to_string(&note.loc)],
                        ),
                        Some(node),
                        Some(String::from("note")),
                    );
                }
            }
        }

        dot.write()
    }
}
