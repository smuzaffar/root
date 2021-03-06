//===- PowerPCInstrFormats.td - PowerPC Instruction Formats --*- tablegen -*-=//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
//
// PowerPC instruction formats

class I<bits<6> opcode, dag OOL, dag IOL, string asmstr, InstrItinClass itin>
        : Instruction {
  field bits<32> Inst;
  field bits<32> SoftFail = 0;
  let Size = 4;

  bit PPC64 = 0;  // Default value, override with isPPC64

  let Namespace = "PPC";
  let Inst{0-5} = opcode;
  let OutOperandList = OOL;
  let InOperandList = IOL;
  let AsmString = asmstr;
  let Itinerary = itin;

  bits<1> PPC970_First = 0;
  bits<1> PPC970_Single = 0;
  bits<1> PPC970_Cracked = 0;
  bits<3> PPC970_Unit = 0;

  /// These fields correspond to the fields in PPCInstrInfo.h.  Any changes to
  /// these must be reflected there!  See comments there for what these are.
  let TSFlags{0}   = PPC970_First;
  let TSFlags{1}   = PPC970_Single;
  let TSFlags{2}   = PPC970_Cracked;
  let TSFlags{5-3} = PPC970_Unit;

  // Fields used for relation models.
  string BaseName = "";

  // For cases where multiple instruction definitions really represent the
  // same underlying instruction but with one definition for 64-bit arguments
  // and one for 32-bit arguments, this bit breaks the degeneracy between
  // the two forms and allows TableGen to generate mapping tables.
  bit Interpretation64Bit = 0;
}

class PPC970_DGroup_First   { bits<1> PPC970_First = 1;  }
class PPC970_DGroup_Single  { bits<1> PPC970_Single = 1; }
class PPC970_DGroup_Cracked { bits<1> PPC970_Cracked = 1; }
class PPC970_MicroCode;

class PPC970_Unit_Pseudo   { bits<3> PPC970_Unit = 0;   }
class PPC970_Unit_FXU      { bits<3> PPC970_Unit = 1;   }
class PPC970_Unit_LSU      { bits<3> PPC970_Unit = 2;   }
class PPC970_Unit_FPU      { bits<3> PPC970_Unit = 3;   }
class PPC970_Unit_CRU      { bits<3> PPC970_Unit = 4;   }
class PPC970_Unit_VALU     { bits<3> PPC970_Unit = 5;   }
class PPC970_Unit_VPERM    { bits<3> PPC970_Unit = 6;   }
class PPC970_Unit_BRU      { bits<3> PPC970_Unit = 7;   }

// Two joined instructions; used to emit two adjacent instructions as one.
// The itinerary from the first instruction is used for scheduling and
// classification.
class I2<bits<6> opcode1, bits<6> opcode2, dag OOL, dag IOL, string asmstr,
         InstrItinClass itin>
        : Instruction {
  field bits<64> Inst;
  field bits<64> SoftFail = 0;
  let Size = 8;

  bit PPC64 = 0;  // Default value, override with isPPC64

  let Namespace = "PPC";
  let Inst{0-5} = opcode1;
  let Inst{32-37} = opcode2;
  let OutOperandList = OOL;
  let InOperandList = IOL;
  let AsmString = asmstr;
  let Itinerary = itin;

  bits<1> PPC970_First = 0;
  bits<1> PPC970_Single = 0;
  bits<1> PPC970_Cracked = 0;
  bits<3> PPC970_Unit = 0;

  /// These fields correspond to the fields in PPCInstrInfo.h.  Any changes to
  /// these must be reflected there!  See comments there for what these are.
  let TSFlags{0}   = PPC970_First;
  let TSFlags{1}   = PPC970_Single;
  let TSFlags{2}   = PPC970_Cracked;
  let TSFlags{5-3} = PPC970_Unit;

  // Fields used for relation models.
  string BaseName = "";
  bit Interpretation64Bit = 0;
}

// 1.7.1 I-Form
class IForm<bits<6> opcode, bit aa, bit lk, dag OOL, dag IOL, string asmstr,
            InstrItinClass itin, list<dag> pattern>
         : I<opcode, OOL, IOL, asmstr, itin> {
  let Pattern = pattern;
  bits<24> LI;

  let Inst{6-29}  = LI;
  let Inst{30}    = aa;
  let Inst{31}    = lk;
}

// 1.7.2 B-Form
class BForm<bits<6> opcode, bit aa, bit lk, dag OOL, dag IOL, string asmstr>
  : I<opcode, OOL, IOL, asmstr, IIC_BrB> {
  bits<7> BIBO;  // 2 bits of BI and 5 bits of BO.
  bits<3>  CR;
  bits<14> BD;

  bits<5> BI;
  let BI{0-1} = BIBO{5-6};
  let BI{2-4} = CR{0-2};

  let Inst{6-10}  = BIBO{4-0};
  let Inst{11-15} = BI;
  let Inst{16-29} = BD;
  let Inst{30}    = aa;
  let Inst{31}    = lk;
}

class BForm_1<bits<6> opcode, bits<5> bo, bit aa, bit lk, dag OOL, dag IOL,
             string asmstr>
  : BForm<opcode, aa, lk, OOL, IOL, asmstr> {
  let BIBO{4-0} = bo;
  let BIBO{6-5} = 0;
  let CR = 0;
}

class BForm_2<bits<6> opcode, bits<5> bo, bits<5> bi, bit aa, bit lk,
              dag OOL, dag IOL, string asmstr>
  : I<opcode, OOL, IOL, asmstr, IIC_BrB> {
  bits<14> BD;

  let Inst{6-10}  = bo;
  let Inst{11-15} = bi;
  let Inst{16-29} = BD;
  let Inst{30}    = aa;
  let Inst{31}    = lk;
}

class BForm_3<bits<6> opcode, bit aa, bit lk,
              dag OOL, dag IOL, string asmstr>
  : I<opcode, OOL, IOL, asmstr, IIC_BrB> {
  bits<5> BO;
  bits<5> BI;
  bits<14> BD;

  let Inst{6-10}  = BO;
  let Inst{11-15} = BI;
  let Inst{16-29} = BD;
  let Inst{30}    = aa;
  let Inst{31}    = lk;
}

class BForm_4<bits<6> opcode, bits<5> bo, bit aa, bit lk,
              dag OOL, dag IOL, string asmstr>
  : I<opcode, OOL, IOL, asmstr, IIC_BrB> {
  bits<5> BI;
  bits<14> BD;

  let Inst{6-10}  = bo;
  let Inst{11-15} = BI;
  let Inst{16-29} = BD;
  let Inst{30}    = aa;
  let Inst{31}    = lk;
}

// 1.7.3 SC-Form
class SCForm<bits<6> opcode, bits<1> xo,
                     dag OOL, dag IOL, string asmstr, InstrItinClass itin,
                     list<dag> pattern>
  : I<opcode, OOL, IOL, asmstr, itin> {
  bits<7>  LEV;

  let Pattern = pattern;

  let Inst{20-26} = LEV;
  let Inst{30}    = xo;
}

// 1.7.4 D-Form
class DForm_base<bits<6> opcode, dag OOL, dag IOL, string asmstr,
                 InstrItinClass itin, list<dag> pattern> 
  : I<opcode, OOL, IOL, asmstr, itin> {
  bits<5>  A;
  bits<5>  B;
  bits<16> C;

  let Pattern = pattern;
  
  let Inst{6-10}  = A;
  let Inst{11-15} = B;
  let Inst{16-31} = C;
}

class DForm_1<bits<6> opcode, dag OOL, dag IOL, string asmstr,
              InstrItinClass itin, list<dag> pattern>
  : I<opcode, OOL, IOL, asmstr, itin> {
  bits<5>  A;
  bits<21> Addr;

  let Pattern = pattern;
  
  let Inst{6-10}  = A;
  let Inst{11-15} = Addr{20-16}; // Base Reg
  let Inst{16-31} = Addr{15-0};  // Displacement
}

class DForm_1a<bits<6> opcode, dag OOL, dag IOL, string asmstr,
               InstrItinClass itin, list<dag> pattern>
  : I<opcode, OOL, IOL, asmstr, itin> {
  bits<5>  A;
  bits<16> C;
  bits<5>  B;

  let Pattern = pattern;
  
  let Inst{6-10}  = A;
  let Inst{11-15} = B;
  let Inst{16-31} = C;
}


class DForm_2<bits<6> opcode, dag OOL, dag IOL, string asmstr,
              InstrItinClass itin, list<dag> pattern>
  : DForm_base<opcode, OOL, IOL, asmstr, itin, pattern> {

  // Even though ADDICo does not really have an RC bit, provide
  // the declaration of one here so that isDOT has something to set.
  bit RC = 0;
}

class DForm_2_r0<bits<6> opcode, dag OOL, dag IOL, string asmstr,
                 InstrItinClass itin, list<dag> pattern>
  : I<opcode, OOL, IOL, asmstr, itin> {
  bits<5>  A;
  bits<16> B;
  
  let Pattern = pattern;
  
  let Inst{6-10}  = A;
  let Inst{11-15} = 0;
  let Inst{16-31} = B;
}

class DForm_4<bits<6> opcode, dag OOL, dag IOL, string asmstr,
              InstrItinClass itin, list<dag> pattern>
  : I<opcode, OOL, IOL, asmstr, itin> {
  bits<5>  B;
  bits<5>  A;
  bits<16> C;
  
  let Pattern = pattern;
  
  let Inst{6-10}  = A;
  let Inst{11-15} = B;
  let Inst{16-31} = C;
}
              
class DForm_4_zero<bits<6> opcode, dag OOL, dag IOL, string asmstr,
                   InstrItinClass itin, list<dag> pattern>
  : DForm_1<opcode, OOL, IOL, asmstr, itin, pattern> {
  let A = 0;
  let Addr = 0;
}

class DForm_4_fixedreg_zero<bits<6> opcode, bits<5> R, dag OOL, dag IOL,
                            string asmstr, InstrItinClass itin,
                            list<dag> pattern>
  : DForm_4<opcode, OOL, IOL, asmstr, itin, pattern> {
  let A = R;
  let B = R;
  let C = 0; 
}

class IForm_and_DForm_1<bits<6> opcode1, bit aa, bit lk, bits<6> opcode2,
            dag OOL, dag IOL, string asmstr,
            InstrItinClass itin, list<dag> pattern>
         : I2<opcode1, opcode2, OOL, IOL, asmstr, itin> {
  bits<5>  A;
  bits<21> Addr;

  let Pattern = pattern;
  bits<24> LI;

  let Inst{6-29}  = LI;
  let Inst{30}    = aa;
  let Inst{31}    = lk;

  let Inst{38-42}  = A;
  let Inst{43-47} = Addr{20-16}; // Base Reg
  let Inst{48-63} = Addr{15-0};  // Displacement
}

// This is used to emit BL8+NOP.
class IForm_and_DForm_4_zero<bits<6> opcode1, bit aa, bit lk, bits<6> opcode2,
            dag OOL, dag IOL, string asmstr,
            InstrItinClass itin, list<dag> pattern>
         :  IForm_and_DForm_1<opcode1, aa, lk, opcode2,
                              OOL, IOL, asmstr, itin, pattern> {
  let A = 0;
  let Addr = 0;
}

class DForm_5<bits<6> opcode, dag OOL, dag IOL, string asmstr,
              InstrItinClass itin>
  : I<opcode, OOL, IOL, asmstr, itin> {
  bits<3>  BF;
  bits<1>  L;
  bits<5>  RA;
  bits<16> I;

  let Inst{6-8}   = BF;
  let Inst{9}     = 0;
  let Inst{10}    = L;
  let Inst{11-15} = RA;
  let Inst{16-31} = I;
}

class DForm_5_ext<bits<6> opcode, dag OOL, dag IOL, string asmstr,
                  InstrItinClass itin>
  : DForm_5<opcode, OOL, IOL, asmstr, itin> {
  let L = PPC64;
}

class DForm_6<bits<6> opcode, dag OOL, dag IOL, string asmstr,
              InstrItinClass itin> 
  : DForm_5<opcode, OOL, IOL, asmstr, itin>;

class DForm_6_ext<bits<6> opcode, dag OOL, dag IOL, string asmstr,
                  InstrItinClass itin>
  : DForm_6<opcode, OOL, IOL, asmstr, itin> {
  let L = PPC64;
}


// 1.7.5 DS-Form
class DSForm_1<bits<6> opcode, bits<2> xo, dag OOL, dag IOL, string asmstr,
               InstrItinClass itin, list<dag> pattern>
         : I<opcode, OOL, IOL, asmstr, itin> {
  bits<5>  RST;
  bits<19> DS_RA;

  let Pattern = pattern;
  
  let Inst{6-10}  = RST;
  let Inst{11-15} = DS_RA{18-14};  // Register #
  let Inst{16-29} = DS_RA{13-0};   // Displacement.
  let Inst{30-31} = xo;
}


// 1.7.6 X-Form
class XForm_base_r3xo<bits<6> opcode, bits<10> xo, dag OOL, dag IOL, string asmstr, 
                      InstrItinClass itin, list<dag> pattern>
  : I<opcode, OOL, IOL, asmstr, itin> {
  bits<5> RST;
  bits<5> A;
  bits<5> B;

  let Pattern = pattern;

  bit RC = 0;    // set by isDOT

  let Inst{6-10}  = RST;
  let Inst{11-15} = A;
  let Inst{16-20} = B;
  let Inst{21-30} = xo;
  let Inst{31}    = RC;
}

class XForm_tlb<bits<10> xo, dag OOL, dag IOL, string asmstr,
                InstrItinClass itin> : XForm_base_r3xo<31, xo, OOL, IOL, asmstr, itin, []> {
  let RST = 0;
}

// This is the same as XForm_base_r3xo, but the first two operands are swapped
// when code is emitted.
class XForm_base_r3xo_swapped
        <bits<6> opcode, bits<10> xo, dag OOL, dag IOL, string asmstr,
        InstrItinClass itin> 
  : I<opcode, OOL, IOL, asmstr, itin> {
  bits<5> A;
  bits<5> RST;
  bits<5> B;

  bit RC = 0;    // set by isDOT

  let Inst{6-10}  = RST;
  let Inst{11-15} = A;
  let Inst{16-20} = B;
  let Inst{21-30} = xo;
  let Inst{31}    = RC;
}


class XForm_1<bits<6> opcode, bits<10> xo, dag OOL, dag IOL, string asmstr,
              InstrItinClass itin, list<dag> pattern> 
  : XForm_base_r3xo<opcode, xo, OOL, IOL, asmstr, itin, pattern>;

class XForm_1a<bits<6> opcode, bits<10> xo, dag OOL, dag IOL, string asmstr,
              InstrItinClass itin, list<dag> pattern>
  : XForm_base_r3xo<opcode, xo, OOL, IOL, asmstr, itin, pattern> {
  let RST = 0;
}

class XForm_rs<bits<6> opcode, bits<10> xo, dag OOL, dag IOL, string asmstr,
              InstrItinClass itin, list<dag> pattern>
  : XForm_base_r3xo<opcode, xo, OOL, IOL, asmstr, itin, pattern> {
  let A = 0;
  let B = 0;
}

class XForm_6<bits<6> opcode, bits<10> xo, dag OOL, dag IOL, string asmstr,
              InstrItinClass itin, list<dag> pattern> 
  : XForm_base_r3xo_swapped<opcode, xo, OOL, IOL, asmstr, itin> {
  let Pattern = pattern;
}

class XForm_8<bits<6> opcode, bits<10> xo, dag OOL, dag IOL, string asmstr,
              InstrItinClass itin, list<dag> pattern> 
  : XForm_base_r3xo<opcode, xo, OOL, IOL, asmstr, itin, pattern>;

class XForm_10<bits<6> opcode, bits<10> xo, dag OOL, dag IOL, string asmstr,
               InstrItinClass itin, list<dag> pattern> 
  : XForm_base_r3xo_swapped<opcode, xo, OOL, IOL, asmstr, itin> {
    let Pattern = pattern;
}

class XForm_11<bits<6> opcode, bits<10> xo, dag OOL, dag IOL, string asmstr,
               InstrItinClass itin, list<dag> pattern> 
  : XForm_base_r3xo_swapped<opcode, xo, OOL, IOL, asmstr, itin> {
  let B = 0;
  let Pattern = pattern;
}

class XForm_16<bits<6> opcode, bits<10> xo, dag OOL, dag IOL, string asmstr,
               InstrItinClass itin>
         : I<opcode, OOL, IOL, asmstr, itin> {
  bits<3> BF;
  bits<1> L; 
  bits<5> RA;
  bits<5> RB;
  
  let Inst{6-8}   = BF;
  let Inst{9}     = 0;
  let Inst{10}    = L;
  let Inst{11-15} = RA;
  let Inst{16-20} = RB;
  let Inst{21-30} = xo;
  let Inst{31}    = 0;
}

class XForm_sr<bits<6> opcode, bits<10> xo, dag OOL, dag IOL, string asmstr,
                InstrItinClass itin>
         : I<opcode, OOL, IOL, asmstr, itin> {
  bits<5> RS;
  bits<4> SR;

  let Inst{6-10} = RS;
  let Inst{12-15} = SR;
  let Inst{21-30} = xo;
}

class XForm_mbar<bits<6> opcode, bits<10> xo, dag OOL, dag IOL, string asmstr,
                InstrItinClass itin>
         : I<opcode, OOL, IOL, asmstr, itin> {
  bits<5> MO;

  let Inst{6-10} = MO;
  let Inst{21-30} = xo;
}

class XForm_srin<bits<6> opcode, bits<10> xo, dag OOL, dag IOL, string asmstr,
                InstrItinClass itin>
         : I<opcode, OOL, IOL, asmstr, itin> {
  bits<5> RS;
  bits<5> RB;

  let Inst{6-10} = RS;
  let Inst{16-20} = RB;
  let Inst{21-30} = xo;
}

class XForm_mtmsr<bits<6> opcode, bits<10> xo, dag OOL, dag IOL, string asmstr,
                InstrItinClass itin>
         : I<opcode, OOL, IOL, asmstr, itin> {
  bits<5> RS;
  bits<1> L;

  let Inst{6-10} = RS;
  let Inst{15} = L;
  let Inst{21-30} = xo;
}

class XForm_16_ext<bits<6> opcode, bits<10> xo, dag OOL, dag IOL, string asmstr,
                   InstrItinClass itin>
  : XForm_16<opcode, xo, OOL, IOL, asmstr, itin> {
  let L = PPC64;
}

class XForm_17<bits<6> opcode, bits<10> xo, dag OOL, dag IOL, string asmstr,
               InstrItinClass itin>
         : I<opcode, OOL, IOL, asmstr, itin> {
  bits<3> BF;
  bits<5> FRA;
  bits<5> FRB;
  
  let Inst{6-8}   = BF;
  let Inst{9-10}  = 0;
  let Inst{11-15} = FRA;
  let Inst{16-20} = FRB;
  let Inst{21-30} = xo;
  let Inst{31}    = 0;
}

class XForm_24<bits<6> opcode, bits<10> xo, dag OOL, dag IOL, string asmstr,
               InstrItinClass itin, list<dag> pattern> 
  : I<opcode, OOL, IOL, asmstr, itin> {
  let Pattern = pattern;
  let Inst{6-10}  = 31;
  let Inst{11-15} = 0;
  let Inst{16-20} = 0;
  let Inst{21-30} = xo;
  let Inst{31}    = 0;
}

class XForm_24_sync<bits<6> opcode, bits<10> xo, dag OOL, dag IOL,
               string asmstr, InstrItinClass itin, list<dag> pattern> 
  : I<opcode, OOL, IOL, asmstr, itin> {
  bits<2> L;

  let Pattern = pattern;
  let Inst{6-8}   = 0;
  let Inst{9-10}  = L;
  let Inst{11-15} = 0;
  let Inst{16-20} = 0;
  let Inst{21-30} = xo;
  let Inst{31}    = 0;
}

class XForm_24_eieio<bits<6> opcode, bits<10> xo, dag OOL, dag IOL,
               string asmstr, InstrItinClass itin, list<dag> pattern> 
  : XForm_24_sync<opcode, xo, OOL, IOL, asmstr, itin, pattern> {
  let L = 0;
}

class XForm_25<bits<6> opcode, bits<10> xo, dag OOL, dag IOL, string asmstr,
               InstrItinClass itin, list<dag> pattern> 
  : XForm_base_r3xo<opcode, xo, OOL, IOL, asmstr, itin, pattern> {
}

class XForm_26<bits<6> opcode, bits<10> xo, dag OOL, dag IOL, string asmstr,
               InstrItinClass itin, list<dag> pattern>
  : XForm_base_r3xo<opcode, xo, OOL, IOL, asmstr, itin, pattern> {
  let A = 0;
}

class XForm_28<bits<6> opcode, bits<10> xo, dag OOL, dag IOL, string asmstr,
               InstrItinClass itin, list<dag> pattern> 
  : XForm_base_r3xo<opcode, xo, OOL, IOL, asmstr, itin, pattern> {
}

// This is used for MFFS, MTFSB0, MTFSB1.  42 is arbitrary; this series of
// numbers presumably relates to some document, but I haven't found it.
class XForm_42<bits<6> opcode, bits<10> xo, dag OOL, dag IOL, string asmstr,
              InstrItinClass itin, list<dag> pattern>
  : XForm_base_r3xo<opcode, xo, OOL, IOL, asmstr, itin, pattern> {
  let Pattern = pattern;

  bit RC = 0;    // set by isDOT

  let Inst{6-10}  = RST;
  let Inst{11-20} = 0;
  let Inst{21-30} = xo;
  let Inst{31}    = RC;
}
class XForm_43<bits<6> opcode, bits<10> xo, dag OOL, dag IOL, string asmstr,
              InstrItinClass itin, list<dag> pattern>
  : XForm_base_r3xo<opcode, xo, OOL, IOL, asmstr, itin, pattern> {
  let Pattern = pattern;
  bits<5> FM;

  bit RC = 0;    // set by isDOT

  let Inst{6-10}  = FM;
  let Inst{11-20} = 0;
  let Inst{21-30} = xo;
  let Inst{31}    = RC;
}

class XForm_0<bits<6> opcode, bits<10> xo, dag OOL, dag IOL, string asmstr,
              InstrItinClass itin, list<dag> pattern>
  : XForm_base_r3xo<opcode, xo, OOL, IOL, asmstr, itin, pattern> {
  let RST = 0;
  let A = 0;
  let B = 0;
}

class XForm_16b<bits<6> opcode, bits<10> xo, dag OOL, dag IOL, string asmstr,
              InstrItinClass itin, list<dag> pattern>
  : XForm_base_r3xo<opcode, xo, OOL, IOL, asmstr, itin, pattern> {
  let RST = 0;
  let A = 0;
}

// XX*-Form (VSX)
class XX1Form<bits<6> opcode, bits<10> xo, dag OOL, dag IOL, string asmstr, 
              InstrItinClass itin, list<dag> pattern>
  : I<opcode, OOL, IOL, asmstr, itin> {
  bits<6> XT;
  bits<5> A;
  bits<5> B;

  let Pattern = pattern;

  let Inst{6-10}  = XT{4-0};
  let Inst{11-15} = A;
  let Inst{16-20} = B;
  let Inst{21-30} = xo;
  let Inst{31}    = XT{5};
}

class XX2Form<bits<6> opcode, bits<9> xo, dag OOL, dag IOL, string asmstr, 
              InstrItinClass itin, list<dag> pattern>
  : I<opcode, OOL, IOL, asmstr, itin> {
  bits<6> XT;
  bits<6> XB;

  let Pattern = pattern;

  let Inst{6-10}  = XT{4-0};
  let Inst{11-15} = 0;
  let Inst{16-20} = XB{4-0};
  let Inst{21-29} = xo;
  let Inst{30}    = XB{5};
  let Inst{31}    = XT{5};
}

class XX2Form_1<bits<6> opcode, bits<9> xo, dag OOL, dag IOL, string asmstr, 
                InstrItinClass itin, list<dag> pattern>
  : I<opcode, OOL, IOL, asmstr, itin> {
  bits<3> CR;
  bits<6> XB;

  let Pattern = pattern;

  let Inst{6-8}   = CR;
  let Inst{9-15}  = 0;
  let Inst{16-20} = XB{4-0};
  let Inst{21-29} = xo;
  let Inst{30}    = XB{5};
  let Inst{31}    = 0;
}

class XX2Form_2<bits<6> opcode, bits<9> xo, dag OOL, dag IOL, string asmstr, 
                InstrItinClass itin, list<dag> pattern>
  : I<opcode, OOL, IOL, asmstr, itin> {
  bits<6> XT;
  bits<6> XB;
  bits<2> D;

  let Pattern = pattern;

  let Inst{6-10}  = XT{4-0};
  let Inst{11-13} = 0;
  let Inst{14-15} = D;
  let Inst{16-20} = XB{4-0};
  let Inst{21-29} = xo;
  let Inst{30}    = XB{5};
  let Inst{31}    = XT{5};
}

class XX3Form<bits<6> opcode, bits<8> xo, dag OOL, dag IOL, string asmstr, 
              InstrItinClass itin, list<dag> pattern>
  : I<opcode, OOL, IOL, asmstr, itin> {
  bits<6> XT;
  bits<6> XA;
  bits<6> XB;

  let Pattern = pattern;

  let Inst{6-10}  = XT{4-0};
  let Inst{11-15} = XA{4-0};
  let Inst{16-20} = XB{4-0};
  let Inst{21-28} = xo;
  let Inst{29}    = XA{5};
  let Inst{30}    = XB{5};
  let Inst{31}    = XT{5};
}

class XX3Form_1<bits<6> opcode, bits<8> xo, dag OOL, dag IOL, string asmstr, 
                InstrItinClass itin, list<dag> pattern>
  : I<opcode, OOL, IOL, asmstr, itin> {
  bits<3> CR;
  bits<6> XA;
  bits<6> XB;

  let Pattern = pattern;

  let Inst{6-8}   = CR;
  let Inst{9-10}  = 0;
  let Inst{11-15} = XA{4-0};
  let Inst{16-20} = XB{4-0};
  let Inst{21-28} = xo;
  let Inst{29}    = XA{5};
  let Inst{30}    = XB{5};
  let Inst{31}    = 0;
}

class XX3Form_2<bits<6> opcode, bits<5> xo, dag OOL, dag IOL, string asmstr, 
                InstrItinClass itin, list<dag> pattern>
  : I<opcode, OOL, IOL, asmstr, itin> {
  bits<6> XT;
  bits<6> XA;
  bits<6> XB;
  bits<2> D;

  let Pattern = pattern;

  let Inst{6-10}  = XT{4-0};
  let Inst{11-15} = XA{4-0};
  let Inst{16-20} = XB{4-0};
  let Inst{21}    = 0;
  let Inst{22-23} = D;
  let Inst{24-28} = xo;
  let Inst{29}    = XA{5};
  let Inst{30}    = XB{5};
  let Inst{31}    = XT{5};
}

class XX3Form_Rc<bits<6> opcode, bits<7> xo, dag OOL, dag IOL, string asmstr, 
              InstrItinClass itin, list<dag> pattern>
  : I<opcode, OOL, IOL, asmstr, itin> {
  bits<6> XT;
  bits<6> XA;
  bits<6> XB;

  let Pattern = pattern;

  bit RC = 0;    // set by isDOT

  let Inst{6-10}  = XT{4-0};
  let Inst{11-15} = XA{4-0};
  let Inst{16-20} = XB{4-0};
  let Inst{21}    = RC;
  let Inst{22-28} = xo;
  let Inst{29}    = XA{5};
  let Inst{30}    = XB{5};
  let Inst{31}    = XT{5};
}

class XX4Form<bits<6> opcode, bits<2> xo, dag OOL, dag IOL, string asmstr, 
              InstrItinClass itin, list<dag> pattern>
  : I<opcode, OOL, IOL, asmstr, itin> {
  bits<6> XT;
  bits<6> XA;
  bits<6> XB;
  bits<6> XC;

  let Pattern = pattern;

  let Inst{6-10}  = XT{4-0};
  let Inst{11-15} = XA{4-0};
  let Inst{16-20} = XB{4-0};
  let Inst{21-25} = XC{4-0};
  let Inst{26-27} = xo;
  let Inst{28}    = XC{5};
  let Inst{29}    = XA{5};
  let Inst{30}    = XB{5};
  let Inst{31}    = XT{5};
}

// DCB_Form - Form X instruction, used for dcb* instructions.
class DCB_Form<bits<10> xo, bits<5> immfield, dag OOL, dag IOL, string asmstr, 
                      InstrItinClass itin, list<dag> pattern>
  : I<31, OOL, IOL, asmstr, itin> {
  bits<5> A;
  bits<5> B;

  let Pattern = pattern;

  let Inst{6-10}  = immfield;
  let Inst{11-15} = A;
  let Inst{16-20} = B;
  let Inst{21-30} = xo;
  let Inst{31}    = 0;
}


// DSS_Form - Form X instruction, used for altivec dss* instructions.
class DSS_Form<bits<10> xo, dag OOL, dag IOL, string asmstr, 
                      InstrItinClass itin, list<dag> pattern>
  : I<31, OOL, IOL, asmstr, itin> {
  bits<1> T;
  bits<2> STRM;
  bits<5> A;
  bits<5> B;

  let Pattern = pattern;

  let Inst{6}     = T;
  let Inst{7-8}   = 0;
  let Inst{9-10}  = STRM;
  let Inst{11-15} = A;
  let Inst{16-20} = B;
  let Inst{21-30} = xo;
  let Inst{31}    = 0;
}

// 1.7.7 XL-Form
class XLForm_1<bits<6> opcode, bits<10> xo, dag OOL, dag IOL, string asmstr,
               InstrItinClass itin, list<dag> pattern>
    : I<opcode, OOL, IOL, asmstr, itin> {
  bits<5> CRD;
  bits<5> CRA;
  bits<5> CRB;
  
  let Pattern = pattern;
  
  let Inst{6-10}  = CRD;
  let Inst{11-15} = CRA;
  let Inst{16-20} = CRB;
  let Inst{21-30} = xo;
  let Inst{31}    = 0;
}

class XLForm_1_ext<bits<6> opcode, bits<10> xo, dag OOL, dag IOL, string asmstr,
               InstrItinClass itin, list<dag> pattern>
    : I<opcode, OOL, IOL, asmstr, itin> {
  bits<5> CRD;
  
  let Pattern = pattern;
  
  let Inst{6-10}  = CRD;
  let Inst{11-15} = CRD;
  let Inst{16-20} = CRD;
  let Inst{21-30} = xo;
  let Inst{31}    = 0;
}

class XLForm_2<bits<6> opcode, bits<10> xo, bit lk, dag OOL, dag IOL, string asmstr, 
               InstrItinClass itin, list<dag> pattern>
    : I<opcode, OOL, IOL, asmstr, itin> {
  bits<5> BO;
  bits<5> BI;
  bits<2> BH;
  
  let Pattern = pattern;
  
  let Inst{6-10}  = BO;
  let Inst{11-15} = BI;
  let Inst{16-18} = 0;
  let Inst{19-20} = BH;
  let Inst{21-30} = xo;
  let Inst{31}    = lk;
}

class XLForm_2_br<bits<6> opcode, bits<10> xo, bit lk,
                  dag OOL, dag IOL, string asmstr, InstrItinClass itin, list<dag> pattern>
  : XLForm_2<opcode, xo, lk, OOL, IOL, asmstr, itin, pattern> {
  bits<7> BIBO;  // 2 bits of BI and 5 bits of BO.
  bits<3>  CR;
  
  let BO = BIBO{4-0};
  let BI{0-1} = BIBO{5-6};
  let BI{2-4} = CR{0-2};
  let BH = 0;
}

class XLForm_2_br2<bits<6> opcode, bits<10> xo, bits<5> bo, bit lk,
                   dag OOL, dag IOL, string asmstr, InstrItinClass itin, list<dag> pattern>
  : XLForm_2<opcode, xo, lk, OOL, IOL, asmstr, itin, pattern> {
  let BO = bo;
  let BH = 0;
}

class XLForm_2_ext<bits<6> opcode, bits<10> xo, bits<5> bo,  bits<5> bi, bit lk,
                  dag OOL, dag IOL, string asmstr, InstrItinClass itin, list<dag> pattern>
  : XLForm_2<opcode, xo, lk, OOL, IOL, asmstr, itin, pattern> {
  let BO = bo;
  let BI = bi;
  let BH = 0;
}

class XLForm_3<bits<6> opcode, bits<10> xo, dag OOL, dag IOL, string asmstr,
               InstrItinClass itin>
         : I<opcode, OOL, IOL, asmstr, itin> {
  bits<3> BF;
  bits<3> BFA;
  
  let Inst{6-8}   = BF;
  let Inst{9-10}  = 0;
  let Inst{11-13} = BFA;
  let Inst{14-15} = 0;
  let Inst{16-20} = 0;
  let Inst{21-30} = xo;
  let Inst{31}    = 0;
}

// 1.7.8 XFX-Form
class XFXForm_1<bits<6> opcode, bits<10> xo, dag OOL, dag IOL, string asmstr,
                InstrItinClass itin>
         : I<opcode, OOL, IOL, asmstr, itin> {
  bits<5>  RT;
  bits<10> SPR;

  let Inst{6-10}  = RT;
  let Inst{11}    = SPR{4};
  let Inst{12}    = SPR{3};
  let Inst{13}    = SPR{2};
  let Inst{14}    = SPR{1};
  let Inst{15}    = SPR{0};
  let Inst{16}    = SPR{9};
  let Inst{17}    = SPR{8};
  let Inst{18}    = SPR{7};
  let Inst{19}    = SPR{6};
  let Inst{20}    = SPR{5};
  let Inst{21-30} = xo;
  let Inst{31}    = 0;
}

class XFXForm_1_ext<bits<6> opcode, bits<10> xo, bits<10> spr, 
                   dag OOL, dag IOL, string asmstr, InstrItinClass itin> 
  : XFXForm_1<opcode, xo, OOL, IOL, asmstr, itin> {
  let SPR = spr;
}

class XFXForm_3<bits<6> opcode, bits<10> xo, dag OOL, dag IOL, string asmstr,
                InstrItinClass itin>
         : I<opcode, OOL, IOL, asmstr, itin> {
  bits<5>  RT;
   
  let Inst{6-10}  = RT;
  let Inst{11-20} = 0;
  let Inst{21-30} = xo;
  let Inst{31}    = 0;
}

class XFXForm_5<bits<6> opcode, bits<10> xo, dag OOL, dag IOL, string asmstr,
                InstrItinClass itin> 
  : I<opcode, OOL, IOL, asmstr, itin> {
  bits<8>  FXM;
  bits<5>  rS;
   
  let Inst{6-10}  = rS;
  let Inst{11}    = 0;
  let Inst{12-19} = FXM;
  let Inst{20}    = 0;
  let Inst{21-30} = xo;
  let Inst{31}    = 0;
}

class XFXForm_5a<bits<6> opcode, bits<10> xo, dag OOL, dag IOL, string asmstr,
                 InstrItinClass itin> 
  : I<opcode, OOL, IOL, asmstr, itin> {
  bits<5>  ST;
  bits<8>  FXM;
   
  let Inst{6-10}  = ST;
  let Inst{11}    = 1;
  let Inst{12-19} = FXM;
  let Inst{20}    = 0;
  let Inst{21-30} = xo;
  let Inst{31}    = 0;
}

class XFXForm_7<bits<6> opcode, bits<10> xo, dag OOL, dag IOL, string asmstr,
                InstrItinClass itin>
  : XFXForm_1<opcode, xo, OOL, IOL, asmstr, itin>;

class XFXForm_7_ext<bits<6> opcode, bits<10> xo, bits<10> spr, 
                    dag OOL, dag IOL, string asmstr, InstrItinClass itin> 
  : XFXForm_7<opcode, xo, OOL, IOL, asmstr, itin> {
  let SPR = spr;
}

// XFL-Form - MTFSF
// This is probably 1.7.9, but I don't have the reference that uses this
// numbering scheme...
class XFLForm<bits<6> opcode, bits<10> xo, dag OOL, dag IOL, string asmstr, 
              InstrItinClass itin, list<dag>pattern>
  : I<opcode, OOL, IOL, asmstr, itin> {
  bits<8> FM;
  bits<5> rT;

  bit RC = 0;    // set by isDOT
  let Pattern = pattern;

  let Inst{6} = 0;
  let Inst{7-14}  = FM;
  let Inst{15} = 0;
  let Inst{16-20} = rT;
  let Inst{21-30} = xo;
  let Inst{31}    = RC;
}

// 1.7.10 XS-Form - SRADI.
class XSForm_1<bits<6> opcode, bits<9> xo, dag OOL, dag IOL, string asmstr,
               InstrItinClass itin, list<dag> pattern>
         : I<opcode, OOL, IOL, asmstr, itin> {
  bits<5> A;
  bits<5> RS;
  bits<6> SH;

  bit RC = 0;    // set by isDOT
  let Pattern = pattern;

  let Inst{6-10}  = RS;
  let Inst{11-15} = A;
  let Inst{16-20} = SH{4,3,2,1,0};
  let Inst{21-29} = xo;
  let Inst{30}    = SH{5};
  let Inst{31}    = RC;
}

// 1.7.11 XO-Form
class XOForm_1<bits<6> opcode, bits<9> xo, bit oe, dag OOL, dag IOL, string asmstr,
               InstrItinClass itin, list<dag> pattern>
         : I<opcode, OOL, IOL, asmstr, itin> {
  bits<5> RT;
  bits<5> RA;
  bits<5> RB;

  let Pattern = pattern;

  bit RC = 0;    // set by isDOT

  let Inst{6-10}  = RT;
  let Inst{11-15} = RA;
  let Inst{16-20} = RB;
  let Inst{21}    = oe;
  let Inst{22-30} = xo;
  let Inst{31}    = RC;  
}

class XOForm_3<bits<6> opcode, bits<9> xo, bit oe, 
               dag OOL, dag IOL, string asmstr, InstrItinClass itin, list<dag> pattern>
  : XOForm_1<opcode, xo, oe, OOL, IOL, asmstr, itin, pattern> {
  let RB = 0;
}

// 1.7.12 A-Form
class AForm_1<bits<6> opcode, bits<5> xo, dag OOL, dag IOL, string asmstr, 
              InstrItinClass itin, list<dag> pattern>
         : I<opcode, OOL, IOL, asmstr, itin> {
  bits<5> FRT;
  bits<5> FRA;
  bits<5> FRC;
  bits<5> FRB;

  let Pattern = pattern;

  bit RC = 0;    // set by isDOT

  let Inst{6-10}  = FRT;
  let Inst{11-15} = FRA;
  let Inst{16-20} = FRB;
  let Inst{21-25} = FRC;
  let Inst{26-30} = xo;
  let Inst{31}    = RC;
}

class AForm_2<bits<6> opcode, bits<5> xo, dag OOL, dag IOL, string asmstr,
              InstrItinClass itin, list<dag> pattern>
  : AForm_1<opcode, xo, OOL, IOL, asmstr, itin, pattern> {
  let FRC = 0;
}

class AForm_3<bits<6> opcode, bits<5> xo, dag OOL, dag IOL, string asmstr,
              InstrItinClass itin, list<dag> pattern> 
  : AForm_1<opcode, xo, OOL, IOL, asmstr, itin, pattern> {
  let FRB = 0;
}

class AForm_4<bits<6> opcode, bits<5> xo, dag OOL, dag IOL, string asmstr, 
              InstrItinClass itin, list<dag> pattern>
         : I<opcode, OOL, IOL, asmstr, itin> {
  bits<5> RT;
  bits<5> RA;
  bits<5> RB;
  bits<5> COND;

  let Pattern = pattern;

  let Inst{6-10}  = RT;
  let Inst{11-15} = RA;
  let Inst{16-20} = RB;
  let Inst{21-25} = COND;
  let Inst{26-30} = xo;
  let Inst{31}    = 0;
}

// 1.7.13 M-Form
class MForm_1<bits<6> opcode, dag OOL, dag IOL, string asmstr,
              InstrItinClass itin, list<dag> pattern>
    : I<opcode, OOL, IOL, asmstr, itin> {
  bits<5> RA;
  bits<5> RS;
  bits<5> RB;
  bits<5> MB;
  bits<5> ME;

  let Pattern = pattern;

  bit RC = 0;    // set by isDOT

  let Inst{6-10}  = RS;
  let Inst{11-15} = RA;
  let Inst{16-20} = RB;
  let Inst{21-25} = MB;
  let Inst{26-30} = ME;
  let Inst{31}    = RC;
}

class MForm_2<bits<6> opcode, dag OOL, dag IOL, string asmstr,
              InstrItinClass itin, list<dag> pattern>
  : MForm_1<opcode, OOL, IOL, asmstr, itin, pattern> {
}

// 1.7.14 MD-Form
class MDForm_1<bits<6> opcode, bits<3> xo, dag OOL, dag IOL, string asmstr,
               InstrItinClass itin, list<dag> pattern>
    : I<opcode, OOL, IOL, asmstr, itin> {
  bits<5> RA;
  bits<5> RS;
  bits<6> SH;
  bits<6> MBE;

  let Pattern = pattern;

  bit RC = 0;    // set by isDOT

  let Inst{6-10}  = RS;
  let Inst{11-15} = RA;
  let Inst{16-20} = SH{4,3,2,1,0};
  let Inst{21-26} = MBE{4,3,2,1,0,5};
  let Inst{27-29} = xo;
  let Inst{30}    = SH{5};
  let Inst{31}    = RC;
}

class MDSForm_1<bits<6> opcode, bits<4> xo, dag OOL, dag IOL, string asmstr,
                InstrItinClass itin, list<dag> pattern>
    : I<opcode, OOL, IOL, asmstr, itin> {
  bits<5> RA;
  bits<5> RS;
  bits<5> RB;
  bits<6> MBE;

  let Pattern = pattern;

  bit RC = 0;    // set by isDOT

  let Inst{6-10}  = RS;
  let Inst{11-15} = RA;
  let Inst{16-20} = RB;
  let Inst{21-26} = MBE{4,3,2,1,0,5};
  let Inst{27-30} = xo;
  let Inst{31}    = RC;
}


// E-1 VA-Form

// VAForm_1 - DACB ordering.
class VAForm_1<bits<6> xo, dag OOL, dag IOL, string asmstr,
               InstrItinClass itin, list<dag> pattern>
    : I<4, OOL, IOL, asmstr, itin> {
  bits<5> VD;
  bits<5> VA;
  bits<5> VC;
  bits<5> VB;

  let Pattern = pattern;
  
  let Inst{6-10}  = VD;
  let Inst{11-15} = VA;
  let Inst{16-20} = VB;
  let Inst{21-25} = VC;
  let Inst{26-31} = xo;
}

// VAForm_1a - DABC ordering.
class VAForm_1a<bits<6> xo, dag OOL, dag IOL, string asmstr,
                InstrItinClass itin, list<dag> pattern>
    : I<4, OOL, IOL, asmstr, itin> {
  bits<5> VD;
  bits<5> VA;
  bits<5> VB;
  bits<5> VC;

  let Pattern = pattern;
  
  let Inst{6-10}  = VD;
  let Inst{11-15} = VA;
  let Inst{16-20} = VB;
  let Inst{21-25} = VC;
  let Inst{26-31} = xo;
}

class VAForm_2<bits<6> xo, dag OOL, dag IOL, string asmstr,
               InstrItinClass itin, list<dag> pattern>
    : I<4, OOL, IOL, asmstr, itin> {
  bits<5> VD;
  bits<5> VA;
  bits<5> VB;
  bits<4> SH;

  let Pattern = pattern;
  
  let Inst{6-10}  = VD;
  let Inst{11-15} = VA;
  let Inst{16-20} = VB;
  let Inst{21}    = 0;
  let Inst{22-25} = SH;
  let Inst{26-31} = xo;
}

// E-2 VX-Form
class VXForm_1<bits<11> xo, dag OOL, dag IOL, string asmstr,
               InstrItinClass itin, list<dag> pattern>
    : I<4, OOL, IOL, asmstr, itin> {
  bits<5> VD;
  bits<5> VA;
  bits<5> VB;
  
  let Pattern = pattern;
  
  let Inst{6-10}  = VD;
  let Inst{11-15} = VA;
  let Inst{16-20} = VB;
  let Inst{21-31} = xo;
}

class VXForm_setzero<bits<11> xo, dag OOL, dag IOL, string asmstr,
               InstrItinClass itin, list<dag> pattern>
    : VXForm_1<xo, OOL, IOL, asmstr, itin, pattern> {
  let VA = VD;
  let VB = VD;
}


class VXForm_2<bits<11> xo, dag OOL, dag IOL, string asmstr,
               InstrItinClass itin, list<dag> pattern>
    : I<4, OOL, IOL, asmstr, itin> {
  bits<5> VD;
  bits<5> VB;
  
  let Pattern = pattern;
  
  let Inst{6-10}  = VD;
  let Inst{11-15} = 0;
  let Inst{16-20} = VB;
  let Inst{21-31} = xo;
}

class VXForm_3<bits<11> xo, dag OOL, dag IOL, string asmstr,
               InstrItinClass itin, list<dag> pattern>
    : I<4, OOL, IOL, asmstr, itin> {
  bits<5> VD;
  bits<5> IMM;
  
  let Pattern = pattern;
  
  let Inst{6-10}  = VD;
  let Inst{11-15} = IMM;
  let Inst{16-20} = 0;
  let Inst{21-31} = xo;
}

/// VXForm_4 - VX instructions with "VD,0,0" register fields, like mfvscr.
class VXForm_4<bits<11> xo, dag OOL, dag IOL, string asmstr,
               InstrItinClass itin, list<dag> pattern>
    : I<4, OOL, IOL, asmstr, itin> {
  bits<5> VD;
  
  let Pattern = pattern;
  
  let Inst{6-10}  = VD;
  let Inst{11-15} = 0;
  let Inst{16-20} = 0;
  let Inst{21-31} = xo;
}

/// VXForm_5 - VX instructions with "0,0,VB" register fields, like mtvscr.
class VXForm_5<bits<11> xo, dag OOL, dag IOL, string asmstr,
               InstrItinClass itin, list<dag> pattern>
    : I<4, OOL, IOL, asmstr, itin> {
  bits<5> VB;
  
  let Pattern = pattern;
  
  let Inst{6-10}  = 0;
  let Inst{11-15} = 0;
  let Inst{16-20} = VB;
  let Inst{21-31} = xo;
}

// E-4 VXR-Form
class VXRForm_1<bits<10> xo, dag OOL, dag IOL, string asmstr,
               InstrItinClass itin, list<dag> pattern>
    : I<4, OOL, IOL, asmstr, itin> {
  bits<5> VD;
  bits<5> VA;
  bits<5> VB;
  bit RC = 0;
  
  let Pattern = pattern;
  
  let Inst{6-10}  = VD;
  let Inst{11-15} = VA;
  let Inst{16-20} = VB;
  let Inst{21}    = RC;
  let Inst{22-31} = xo;
}

//===----------------------------------------------------------------------===//
class Pseudo<dag OOL, dag IOL, string asmstr, list<dag> pattern>
    : I<0, OOL, IOL, asmstr, NoItinerary> {
  let isCodeGenOnly = 1;
  let PPC64 = 0;
  let Pattern = pattern;
  let Inst{31-0} = 0;
}
