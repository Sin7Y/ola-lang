use super::util::{spaces, string_literal};
use super::value::parse_constant;
use crate::codegen::core::ir::module::{metadata::Metadata, name::Name};
use crate::codegen::core::ir::types;
use nom::combinator::opt;
use nom::{
    branch::alt,
    bytes::complete::tag,
    character::complete::char,
    error::VerboseError,
    multi::separated_list0,
    sequence::{preceded, separated_pair, tuple},
    IResult,
};

pub fn parse(
    types: &types::Types,
) -> impl Fn(&str) -> IResult<&str, (Name, Metadata), VerboseError<&str>> + '_ {
    move |source| {
        separated_pair(
            preceded(exclamation, super::name::parse),
            preceded(spaces, tag("=")),
            node(types),
        )(source)
    }
}

fn exclamation(source: &str) -> IResult<&str, &str, VerboseError<&str>> {
    preceded(spaces, tag("!"))(source)
}

fn string(source: &str) -> IResult<&str, Metadata, VerboseError<&str>> {
    preceded(exclamation, preceded(spaces, string_literal))(source)
        .map(|(i, source)| (i, Metadata::String(source)))
}

fn name(source: &str) -> IResult<&str, Metadata, VerboseError<&str>> {
    preceded(exclamation, super::name::parse)(source).map(|(i, source)| (i, Metadata::Name(source)))
}

fn int(types: &types::Types) -> impl Fn(&str) -> IResult<&str, Metadata, VerboseError<&str>> + '_ {
    move |source| {
        let (source, ty) = super::types::parse(types)(source)?;
        parse_constant(source, types, ty).map(|(source, v)| (source, Metadata::Const(v)))
    }
}

fn node(types: &types::Types) -> impl Fn(&str) -> IResult<&str, Metadata, VerboseError<&str>> + '_ {
    move |source| {
        tuple((
            spaces,
            opt(tag("distinct")),
            exclamation,
            spaces,
            char('{'),
            separated_list0(preceded(spaces, tag(",")), operand(types)),
            spaces,
            char('}'),
        ))(source)
        .map(|(i, (_, distinct, _, _, _, list, _, _))| {
            (i, Metadata::Node(list, distinct.is_some()))
        })
    }
}

pub fn operand(
    types: &types::Types,
) -> impl Fn(&str) -> IResult<&str, Metadata, VerboseError<&str>> + '_ {
    move |source| alt((string, name, node(types), int(types)))(source)
}
