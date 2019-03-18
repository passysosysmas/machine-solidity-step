/// @title ArithmeticImmediateInstructions
pragma solidity ^0.5.0;

import "../../contracts/MemoryInteractor.sol";
import "../../contracts/RiscVDecoder.sol";
import "../../contracts/RiscVConstants.sol";

library ArithmeticImmediateInstructions {

  function get_rs1_imm(MemoryInteractor mi, uint256 mmIndex, uint32 insn) internal 
  returns(uint64 rs1, int32 imm) {
    rs1 = mi.read_x(mmIndex, RiscVDecoder.insn_rs1(insn));
    imm = RiscVDecoder.insn_I_imm(insn);
  }

  // ADDI adds the sign extended 12 bits immediate to rs1. Overflow is ignored.
  // Reference: riscv-spec-v2.2.pdf -  Page 13
  function execute_ADDI(MemoryInteractor mi, uint256 mmIndex, uint32 insn) public returns (uint64){
    (uint64 rs1, int32 imm) = get_rs1_imm(mi, mmIndex, insn);
    return rs1 + uint64(imm);
  }

  // ADDIW adds the sign extended 12 bits immediate to rs1 and produces to correct
  // sign extension for 32 bits at rd. Overflow is ignored and the result is the
  // low 32 bits of the result sign extended to 64 bits.
  // Reference: riscv-spec-v2.2.pdf -  Page 30
  function execute_ADDIW(MemoryInteractor mi, uint256 mmIndex, uint32 insn) public returns (uint64){
    (uint64 rs1, int32 imm) = get_rs1_imm(mi, mmIndex, insn);
    return uint64(int32(rs1) + imm);
  }

  // SLLIW is analogous to SLLI but operate on 32 bit values.
  // The amount of shifts are enconded on the lower 5 bits of I-imm.
  // Reference: riscv-spec-v2.2.pdf - Section 4.2 -  Page 30
  function execute_SLLIW(MemoryInteractor mi, uint256 mmIndex, uint32 insn) public returns (uint64){
    (uint64 rs1, int32 imm) = get_rs1_imm(mi, mmIndex, insn);
    int32 rs1w = int32(rs1) << (imm & 0x1F);
    return uint64(rs1w);
  }

  // ORI performs logical Or bitwise operation on register rs1 and the sign-extended
  // 12 bit immediate. It places the result in rd.
  // Reference: riscv-spec-v2.2.pdf - Section 2.4 -  Page 14
  function execute_ORI(MemoryInteractor mi, uint256 mmIndex, uint32 insn) public returns (uint64){
    (uint64 rs1, int32 imm) = get_rs1_imm(mi, mmIndex, insn);
    return rs1 | uint64(imm);
  }

  // SLLI performs the logical left shift. The operand to be shifted is in rs1
  // and the amount of shifts are encoded on the lower 6 bits of I-imm.(RV64)
  // Reference: riscv-spec-v2.2.pdf - Section 2.4 -  Page 14
  function execute_SLLI(MemoryInteractor mi, uint256 mmIndex, uint32 insn) public returns(uint64){
    (uint64 rs1, int32 imm) = get_rs1_imm(mi, mmIndex, insn);
    return rs1 << (imm & 0x3F);
  }

  // SLRI instructions is a logical shift right instruction. The variable to be 
  // shift is in rs1 and the amount of shift operations is encoded in the lower
  // 6 bits of the I-immediate field.
  function execute_SRLI(MemoryInteractor mi, uint256 mmIndex, uint32 insn) public returns(uint64){
    // Get imm's lower 6 bits
    (uint64 rs1, int32 imm) = get_rs1_imm(mi, mmIndex, insn);
    int32 shiftAmount = imm & int32(RiscVConstants.XLEN() - 1);

    return rs1 >> shiftAmount;
  }

  // SRLIW instructions operates on a 32bit value and produce a signed results.
  // The variable to be shift is in rs1 and the amount of shift operations is 
  // encoded in the lower 6 bits of the I-immediate field.
  function execute_SRLIW(MemoryInteractor mi, uint256 mmIndex, uint32 insn) public returns(uint64){
    // Get imm's lower 6 bits
    (uint64 rs1, int32 imm) = get_rs1_imm(mi, mmIndex, insn);
    int32 rs1w = int32(uint32(rs1) >> (imm & 0x1F));
    return uint64(rs1w);
  }
  // SLTIU is analogous to SLLTI but treats imm as unsigned.
  // Reference: riscv-spec-v2.2.pdf - Section 2.4 -  Page 14
  function execute_SLTIU(MemoryInteractor mi, uint256 mmIndex, uint32 insn) public returns (uint64){
    (uint64 rs1, int32 imm) = get_rs1_imm(mi, mmIndex, insn);
    return rs1 < uint64(imm);
  }
  // SRAIW instructions operates on a 32bit value and produce a signed results.
  // The variable to be shift is in rs1 and the amount of shift operations is 
  // encoded in the lower 6 bits of the I-immediate field.
  function execute_SRAIW(MemoryInteractor mi, uint256 mmIndex, uint32 insn) public returns(uint64){
    // Get imm's lower 6 bits
    (uint64 rs1, int32 imm) = get_rs1_imm(mi, mmIndex, insn);
    int32 rs1w = int32(rs1) >> (imm & 0x1F);
    return uint64(rs1w);
  }

  // XORI instructions performs XOR operation on register rs1 and hhe sign extended
  // 12 bit immediate, placing result in rd.
  function execute_XORI(MemoryInteractor mi, uint256 mmIndex, uint32 insn) public returns(uint64){
    // Get imm's lower 6 bits
    (uint64 rs1, int32 imm) = get_rs1_imm(mi, mmIndex, insn);
    return rs1 ^ uint64(imm);
  }

  // ANDI instructions performs AND operation on register rs1 and hhe sign extended
  // 12 bit immediate, placing result in rd.                                                      }
  function execute_ANDI(MemoryInteractor mi, uint256 mmIndex, uint32 insn) public returns(uint64){
    // Get imm's lower 6 bits
    (uint64 rs1, int32 imm) = get_rs1_imm(mi, mmIndex, insn);
    return rs1 & uint64(imm);
  }
