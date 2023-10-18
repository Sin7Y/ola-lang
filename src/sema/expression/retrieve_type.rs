use crate::sema::ast::{Expression, RetrieveType, Type};

impl RetrieveType for Expression {
    fn ty(&self) -> Type {
        match self {
            Expression::BoolLiteral { .. }
            | Expression::More { .. }
            | Expression::Less { .. }
            | Expression::MoreEqual { .. }
            | Expression::LessEqual { .. }
            | Expression::Equal { .. }
            | Expression::Or { .. }
            | Expression::And { .. }
            | Expression::NotEqual { .. }
            | Expression::Not { .. }
            | Expression::StringCompare { .. } => Type::Bool,
            Expression::StringConcat { ty, .. }
            | Expression::BytesLiteral { ty, .. }
            | Expression::NumberLiteral { ty, .. }
            | Expression::AddressLiteral { ty, .. }
            | Expression::HashLiteral { ty, .. }
            | Expression::StructLiteral { ty, .. }
            | Expression::ArrayLiteral { ty, .. }
            | Expression::ConstArrayLiteral { ty, .. }
            | Expression::Add { ty, .. }
            | Expression::Subtract { ty, .. }
            | Expression::Multiply { ty, .. }
            | Expression::Divide { ty, .. }
            | Expression::Modulo { ty, .. }
            | Expression::Power { ty, .. }
            | Expression::BitwiseOr { ty, .. }
            | Expression::BitwiseAnd { ty, .. }
            | Expression::BitwiseXor { ty, .. }
            | Expression::ShiftLeft { ty, .. }
            | Expression::ShiftRight { ty, .. }
            | Expression::Variable { ty, .. }
            | Expression::ConstantVariable { ty, .. }
            | Expression::StorageVariable { ty, .. }
            | Expression::Load { ty, .. }
            | Expression::GetRef { ty, .. }
            | Expression::StorageLoad { ty, .. }
            | Expression::BitwiseNot { ty, .. }
            | Expression::ConditionalOperator { ty, .. }
            | Expression::StructMember { ty, .. }
            | Expression::AllocDynamicBytes { ty, .. }
            | Expression::Increment { ty, .. }
            | Expression::Decrement { ty, .. }
            | Expression::Assign { ty, .. } => ty.clone(),
            Expression::Subscript { ty, .. } => ty.clone(),
            Expression::ArraySlice { .. } => Type::DynamicBytes,
            Expression::ZeroExt { to, .. }
            | Expression::Trunc { to, .. }
            | Expression::Cast { to, .. }
            | Expression::BytesCast { to, .. } => to.clone(),
            Expression::StorageArrayLength { ty, .. } => ty.clone(),
            Expression::ExternalFunctionCallRaw { .. } => Type::DynamicBytes,
            Expression::LibFunction { tys: returns, .. }
            | Expression::FunctionCall { returns, .. } => {
                assert_eq!(returns.len(), 1);
                returns[0].clone()
            }
            Expression::List { list, .. } => {
                assert_eq!(list.len(), 1);

                list[0].ty()
            }
            Expression::Function { ty, .. } => ty.clone(),
        }
    }
}
