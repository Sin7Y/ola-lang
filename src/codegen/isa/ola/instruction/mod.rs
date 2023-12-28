use crate::codegen::{
    function::{
        basic_block::BasicBlockId,
        instruction::{Instruction, InstructionId, TargetInst},
        slot::SlotId,
        Function,
    },
    isa::{
        ola::register::{reg_to_str, GR},
        TargetIsa,
    },
    register::{Reg, VReg, VRegUsers},
};
use std::fmt;

#[derive(Clone)]
pub struct InstructionData {
    pub opcode: Opcode,
    pub operands: Vec<Operand>,
}

#[derive(Debug, Copy, Clone, PartialEq, Eq)]
pub enum Opcode {
    ADDri,
    ADDrr,
    MULri,
    MULrr,

    ANDri,
    ANDrr,
    ORri,
    ORrr,
    XORri,
    XORrr,

    EQri,
    EQrr,
    ASSERTri,
    ASSERTrr,

    MOVri,
    MOVrr,
    MOV,

    JMPi,
    JMPr,
    CJMPi,
    CJMPr,
    CALL,
    SCCALL,
    RET,
    END,

    SLOAD,
    SSTORE,
    POSEIDON,

    MLOADi,
    MLOADr,
    MSTOREi,
    MSTOREr,

    RANGECHECK,
    SIGCHECK,
    NOT,
    NEQ,
    GTE,

    PROPHET,

    Phi,

    TLOADri,
    TLOADrr,
    TSTOREi,
    TSTOREr,
}

#[derive(Clone)]
pub struct Operand {
    pub data: OperandData,
    pub input: bool,
    pub output: bool,
    pub implicit: bool,
}

#[derive(Clone)]
pub enum OperandData {
    Reg(Reg),
    VReg(VReg),
    Int8(i8),
    Int32(i32),
    Int64(i64),
    MemStart,
    Slot(SlotId),
    Block(BasicBlockId),
    Label(String),
    GlobalAddress(String),
    None,
}

impl TargetInst for InstructionData {
    fn input_vregs(&self) -> Vec<VReg> {
        let mut vrs = vec![];
        for operand in &self.operands {
            if let Operand {
                data: OperandData::VReg(vr),
                input: true,
                ..
            } = operand
            {
                vrs.push(*vr)
            }
        }
        vrs
    }

    fn input_vregs_with_indexes(&self) -> Vec<(usize, VReg)> {
        let mut list = vec![];
        for (i, operand) in self.operands.iter().enumerate() {
            if let Operand {
                data: OperandData::VReg(vr),
                input: true,
                ..
            } = operand
            {
                list.push((i, *vr))
            }
        }
        list
    }

    fn output_vregs(&self) -> Vec<VReg> {
        let mut vrs = vec![];
        for operand in &self.operands {
            if let Operand {
                data: OperandData::VReg(vr),
                output: true,
                ..
            } = operand
            {
                vrs.push(*vr)
            }
        }
        vrs
    }

    fn all_vregs(&self) -> Vec<VReg> {
        let mut list = vec![];
        for operand in &self.operands {
            if let Operand {
                data: OperandData::VReg(r),
                ..
            } = operand
            {
                list.push(*r)
            }
        }
        list
    }

    fn input_regs(&self) -> Vec<Reg> {
        let mut rs = vec![];
        for operand in &self.operands {
            if let Operand {
                data: OperandData::Reg(r),
                input: true,
                ..
            } = operand
            {
                rs.push(*r)
            }
        }
        rs
    }

    fn output_regs(&self) -> Vec<Reg> {
        let mut rs = vec![];
        for operand in &self.operands {
            if let Operand {
                data: OperandData::Reg(r),
                output: true,
                ..
            } = operand
            {
                rs.push(*r)
            }
        }
        rs
    }

    fn all_regs(&self) -> Vec<Reg> {
        let mut list = vec![];
        for operand in &self.operands {
            if let Operand {
                data: OperandData::Reg(r),
                ..
            } = operand
            {
                list.push(*r)
            }
        }
        list
    }

    fn rewrite(&mut self, vreg: VReg, reg: Reg) {
        for operand in &mut self.operands {
            match operand.data {
                OperandData::VReg(vr) if vr == vreg => operand.data = OperandData::Reg(reg),
                _ => {}
            }
        }
    }

    fn replace_vreg(
        &mut self,
        self_id: InstructionId<Self>,
        users: &mut VRegUsers<Self>,
        from: VReg,
        to: VReg,
    ) {
        let u = users.remove_use(from, self_id).unwrap();
        users.add_use(to, self_id, u.read, u.write);
        for operand in &mut self.operands {
            match operand.data {
                OperandData::VReg(r) if r == from => operand.data = OperandData::VReg(to),
                _ => {}
            }
        }
    }

    fn block_at(&self, i: usize) -> Option<BasicBlockId> {
        self.operands.get(i).and_then(|data| match data.data {
            OperandData::Block(b) => Some(b),
            _ => None,
        })
    }

    fn is_copy(&self) -> bool {
        matches!(self.opcode, Opcode::MOVri | Opcode::MOVrr)
    }

    fn is_call(&self) -> bool {
        self.opcode == Opcode::CALL
    }

    fn is_phi(&self) -> bool {
        self.opcode == Opcode::Phi
    }

    fn store_vreg_to_slot<T: TargetIsa>(
        f: &Function<T>,
        vreg: VReg,
        slot: SlotId,
        block: BasicBlockId,
    ) -> Instruction<Self> {
        let ty = f.data.vregs.type_for(vreg);
        let sz = f.isa.data_layout().get_size_of(&f.types, ty);
        assert!(sz == 4);
        Instruction::new(
            InstructionData {
                opcode: match sz {
                    4 => Opcode::MSTOREr,
                    _ => unreachable!(),
                },
                operands: vec![
                    Operand::new(OperandData::MemStart),
                    Operand::new(OperandData::None),
                    Operand::new(OperandData::Slot(slot)),
                    Operand::new(OperandData::None),
                    Operand::input(OperandData::None),
                    Operand::input(OperandData::None),
                    Operand::new(OperandData::None),
                    Operand::input(vreg.into()),
                ],
            },
            block,
        )
    }

    fn load_from_slot<T: TargetIsa>(
        f: &Function<T>,
        vreg: VReg,
        slot: SlotId,
        block: BasicBlockId,
    ) -> Instruction<Self> {
        let ty = f.data.vregs.type_for(vreg);
        let sz = f.isa.data_layout().get_size_of(&f.types, ty);
        assert!(sz == 4 || sz == 8);
        Instruction::new(
            InstructionData {
                opcode: match sz {
                    4 => Opcode::MLOADr,
                    _ => unreachable!(),
                },
                operands: vec![
                    Operand::output(vreg.into()),
                    Operand::new(OperandData::MemStart),
                    Operand::new(OperandData::None),
                    Operand::new(OperandData::Slot(slot)),
                    Operand::new(OperandData::None),
                    Operand::input(OperandData::None),
                    Operand::input(OperandData::None),
                    Operand::new(OperandData::None),
                ],
            },
            block,
        )
    }
}

impl Operand {
    pub fn new(data: OperandData) -> Self {
        Self {
            data,
            input: false,
            output: false,
            implicit: false,
        }
    }

    pub fn input(data: OperandData) -> Self {
        Self {
            data,
            input: true,
            output: false,
            implicit: false,
        }
    }

    pub fn output(data: OperandData) -> Self {
        Self {
            data,
            input: false,
            output: true,
            implicit: false,
        }
    }

    pub fn implicit_output(data: OperandData) -> Self {
        Self {
            data,
            input: false,
            output: true,
            implicit: true,
        }
    }

    pub fn input_output(data: OperandData) -> Self {
        Self {
            data,
            input: true,
            output: true,
            implicit: false,
        }
    }
}

impl OperandData {
    pub fn as_reg(&self) -> &Reg {
        match self {
            Self::Reg(r) => r,
            e => todo!("{:?}", e),
        }
    }

    pub fn as_vreg(&self) -> &VReg {
        match self {
            Self::VReg(r) => r,
            _ => todo!(),
        }
    }

    pub fn as_block(&self) -> &BasicBlockId {
        match self {
            Self::Block(b) => b,
            _ => todo!(),
        }
    }

    pub fn sext_as_i64(&self) -> Option<i64> {
        match self {
            Self::Int64(i) => Some(*i),
            Self::Int32(i) => Some(*i as i64),
            Self::Int8(i) => Some(*i as i64),
            _ => None,
        }
    }
}

impl From<VReg> for OperandData {
    fn from(r: VReg) -> Self {
        OperandData::VReg(r)
    }
}

impl From<Reg> for OperandData {
    fn from(r: Reg) -> Self {
        OperandData::Reg(r)
    }
}

impl From<&VReg> for OperandData {
    fn from(r: &VReg) -> Self {
        OperandData::VReg(*r)
    }
}

impl From<&Reg> for OperandData {
    fn from(r: &Reg) -> Self {
        OperandData::Reg(*r)
    }
}

impl From<i8> for OperandData {
    fn from(i: i8) -> Self {
        OperandData::Int8(i)
    }
}

impl From<&i8> for OperandData {
    fn from(i: &i8) -> Self {
        OperandData::Int8(*i)
    }
}

impl From<i32> for OperandData {
    fn from(i: i32) -> Self {
        OperandData::Int32(i)
    }
}

impl From<&i32> for OperandData {
    fn from(i: &i32) -> Self {
        OperandData::Int32(*i)
    }
}

impl From<i64> for OperandData {
    fn from(i: i64) -> Self {
        OperandData::Int64(i)
    }
}

impl From<&i64> for OperandData {
    fn from(i: &i64) -> Self {
        OperandData::Int64(*i)
    }
}

impl From<GR> for OperandData {
    fn from(r: GR) -> Self {
        OperandData::Reg(r.into())
    }
}

impl fmt::Debug for InstructionData {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{:?} ", self.opcode)?;
        for (i, op) in self.operands.iter().enumerate() {
            write!(f, "{:?}", op)?;
            if i < self.operands.len() - 1 {
                write!(f, ", ")?
            }
        }
        Ok(())
    }
}

impl fmt::Debug for Operand {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let mut flags = vec![];
        // if self.input {
        //     flags.push("use")
        // }
        if self.output {
            flags.push("def")
        }
        if self.input {
            flags.push("use")
        }
        if self.implicit {
            flags.push("imp")
        }
        write!(f, "{:?}", self.data)?;
        if !flags.is_empty() {
            write!(f, "<")?;
            for (i, flag) in flags.iter().enumerate() {
                write!(f, "{}", flag)?;
                if i < flags.len() - 1 {
                    write!(f, ", ")?
                }
            }
            write!(f, ">")?;
        }
        Ok(())
    }
}

impl fmt::Debug for OperandData {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::Reg(r) => write!(f, "{}", reg_to_str(r)),
            Self::VReg(vr) => write!(f, "%{}", vr.0),
            Self::Int8(i) => write!(f, "{}", i),
            Self::Int32(i) => write!(f, "{}", i),
            Self::Int64(i) => write!(f, "{}", i),
            Self::MemStart => write!(f, "$MemStart$"),
            Self::Slot(slot) => write!(f, "slot.{}", slot.index()),
            Self::Block(id) => write!(f, "block.{}", id.index()),
            Self::Label(name) => write!(f, "{}", name),
            Self::GlobalAddress(name) => write!(f, "{}", name),
            Self::None => write!(f, "none"),
        }
    }
}
