--Hasquil instructions
--Copyright Laurence Emms 2018

module Instruction (Instruction(..),
                    Circuit(..)) where

import Data.Char
import Register

data Instruction a
    = PauliI Quantum | --Quantum instructions
      PauliX Quantum |                    
      PauliY Quantum |                    
      PauliZ Quantum |
      Hadamard Quantum |
      Phase (Classical a) Quantum |
      PhaseS Quantum |
      PhaseT Quantum |
      CPhase00 (Classical a) Quantum Quantum |
      CPhase01 (Classical a) Quantum Quantum |
      CPhase10 (Classical a) Quantum Quantum |
      CPhase (Classical a) Quantum Quantum |
      RX (Classical a) Quantum |
      RY (Classical a) Quantum |
      RZ (Classical a) Quantum |
      CNot Quantum Quantum |
      CCNot Quantum Quantum Quantum Quantum |
      PSwap (Classical a) Quantum Quantum |
      Swap Quantum Quantum |
      ISwap Quantum Quantum |
      CSwap Quantum Quantum Quantum Quantum |
      Measure Quantum |
      MeasureOut Quantum (Classical a) |
      Reset |
      Halt | --Classical instructions
      Jump String |
      JumpWhen String (Classical a) |
      JumpUnless String (Classical a) |
      Label String |
      Nop |
      IFalse (Classical a) |
      ITrue (Classical a) |
      INot (Classical a) |
      IAnd (Classical a) (Classical a) |
      IOr (Classical a) (Classical a) |
      Move (Classical a) (Classical a) |
      Exchange (Classical a) (Classical a) |
      Pragma String |
      DefCircuit (Circuit a) |
      CallCircuit (Circuit a) [Either Quantum (Classical a)]

instance (Floating a, Show a, Ord a) => Show (Instruction a) where
    show (PauliI q) = "I " ++ (show q)
    show (PauliX q) = "X " ++ (show q)
    show (PauliY q) = "Y " ++ (show q)
    show (PauliZ q) = "Z " ++ (show q)
    show (Hadamard q) = "H " ++ (show q)
    show (Phase c q) = "PHASE(" ++ (show c) ++ ") " ++ (show q)
    show (PhaseS q) = "S " ++ (show q)
    show (PhaseT q) = "T " ++ (show q)
    show (CPhase00 c q0 q1) = "CPHASE00(" ++ (show c) ++ ") " ++ (show q0) ++ " " ++ (show q1)
    show (CPhase01 c q0 q1) = "CPHASE01(" ++ (show c) ++ ") " ++ (show q0) ++ " " ++ (show q1)
    show (CPhase10 c q0 q1) = "CPHASE10(" ++ (show c) ++ ") " ++ (show q0) ++ " " ++ (show q1)
    show (CPhase c q0 q1) = "CPHASE(" ++ (show c) ++ ") " ++ (show q0) ++ " " ++ (show q1)
    show (RX c q) = "RX(" ++ (show c) ++ ") " ++ (show q)
    show (RY c q) = "RY(" ++ (show c) ++ ") " ++ (show q)
    show (RZ c q) = "RZ(" ++ (show c) ++ ") " ++ (show q)
    show (CNot q0 q1) = "CNOT " ++ (show q0) ++ " " ++ (show q1)
    show (CCNot q0 q1 q2 q3) = "CCNOT " ++ (show q0) ++ " " ++ (show q1) ++ (show q2) ++ " " ++ (show q3)
    show (PSwap c q0 q1) = "PSWAP(" ++ (show c) ++ ") " ++ (show q0) ++ " " ++ (show q1)
    show (Swap q0 q1) = "SWAP " ++ (show q0) ++ " " ++ (show q1)
    show (ISwap q0 q1) = "ISWAP " ++ (show q0) ++ " " ++ (show q1)
    show (CSwap q0 q1 q2 q3) = "CSWAP " ++ (show q0) ++ " " ++ (show q1) ++ (show q2) ++ " " ++ (show q3)
    show (Measure q) = "MEASURE " ++ (show q)
    show (MeasureOut q (Register r)) = "MEASURE " ++ (show q) ++ " " ++ (show (Register r))
    show (MeasureOut q (MetaRegister m)) = "MEASURE " ++ (show q) ++ " " ++ (show (MetaRegister m))
    show (Reset) = "RESET"
    show Halt = "HALT"
    show (Jump s) = "JUMP @" ++ (fmap toUpper s)
    show (JumpWhen s (Register r)) = "JUMP-WHEN @" ++ (fmap toUpper s) ++ " " ++ (show (Register r))
    show (JumpUnless s (Register r)) = "JUMP-UNLESS @" ++ (fmap toUpper s) ++ " " ++ (show (Register r))
    show (Label s) = "LABEL @" ++ (fmap toUpper s)
    show Nop = "NOP"
    show (IFalse (Register r)) = "FALSE " ++ (show (Register r))
    show (ITrue (Register r)) = "TRUE " ++ (show (Register r))
    show (INot (Register r)) = "NOT " ++ (show (Register r))
    show (IAnd (Register r0) (Register r1)) = "AND " ++ (show (Register r0)) ++ " " ++ (show (Register r1))
    show (IOr (Register r0) (Register r1)) = "OR " ++ (show (Register r0)) ++ " " ++ (show (Register r1))
    show (Move (Register r0) (Register r1)) = "MOVE " ++ (show (Register r0)) ++ " " ++ (show (Register r1))
    show (Exchange (Register r0) (Register r1)) = "EXCHANGE " ++ (show (Register r0)) ++ " " ++ (show (Register r1))
    show (Pragma s) = "PRAGMA " ++ s
    show (DefCircuit c) = showDefCircuit c
    show (CallCircuit c arguments) = showCallCircuit c arguments

--Circuit type
data Circuit a = Circuit String [Either Quantum (Classical a)] [Instruction a]

--Circuit definition
showDefCircuit :: (Floating a, Show a, Ord a) => Circuit a -> String
showDefCircuit (Circuit _ _ []) = []
showDefCircuit (Circuit name parameters instructions) = "DEFCIRCUIT " ++ (fmap toUpper name) ++ (defCircuitParameters parameters instructions)

defCircuitParameters :: (Floating a, Show a, Ord a) => [Either Quantum (Classical a)] -> [Instruction a] -> String
defCircuitParameters [] instructions = ":\n" ++ (defCircuitInstructions instructions)
defCircuitParameters (Left r@(MetaQubitRegister _) : parameters) instructions = " " ++ (show  r) ++ (defCircuitParameters parameters instructions)
defCircuitParameters (Right r@(MetaRegister _) : parameters) instructions = " " ++ (show r) ++ (defCircuitParameters parameters instructions)

circuitInstruction (instruction : instructions) = "    " ++ (show instruction) ++ "\n" ++ (defCircuitInstructions instructions)

defCircuitInstructions :: (Floating a, Show a, Ord a) => [Instruction a] -> String
defCircuitInstructions [] = []
defCircuitInstructions (instruction@(PauliI (MetaQubitRegister _)) : instructions) = circuitInstruction (instruction : instructions)
defCircuitInstructions (instruction@(PauliX (MetaQubitRegister _)) : instructions) = circuitInstruction (instruction : instructions)
defCircuitInstructions (instruction@(PauliY (MetaQubitRegister _)) : instructions) = circuitInstruction (instruction : instructions)
defCircuitInstructions (instruction@(PauliZ (MetaQubitRegister _)) : instructions) = circuitInstruction (instruction : instructions)
defCircuitInstructions (instruction@(Hadamard (MetaQubitRegister _)) : instructions) = circuitInstruction (instruction : instructions)

defCircuitInstructions (instruction@(Phase (RealConstant _) (MetaQubitRegister _)) : instructions) = circuitInstruction (instruction : instructions)
defCircuitInstructions (instruction@(Phase (ComplexConstant _) (MetaQubitRegister _)) : instructions) = circuitInstruction (instruction : instructions)
defCircuitInstructions (instruction@(Phase (MetaRegister _) (MetaQubitRegister _)) : instructions) = circuitInstruction (instruction : instructions)

defCircuitInstructions (instruction@(PhaseS (MetaQubitRegister _)) : instructions) = circuitInstruction (instruction : instructions)
defCircuitInstructions (instruction@(PhaseT (MetaQubitRegister _)) : instructions) = circuitInstruction (instruction : instructions)

defCircuitInstructions (instruction@(CPhase00 (RealConstant _) (MetaQubitRegister _) (MetaQubitRegister _)) : instructions) = circuitInstruction (instruction : instructions)
defCircuitInstructions (instruction@(CPhase00 (ComplexConstant _) (MetaQubitRegister _) (MetaQubitRegister _)) : instructions) = circuitInstruction (instruction : instructions)
defCircuitInstructions (instruction@(CPhase00 (MetaRegister _) (MetaQubitRegister _) (MetaQubitRegister _)) : instructions) = circuitInstruction (instruction : instructions)

defCircuitInstructions (instruction@(CPhase01 (RealConstant _) (MetaQubitRegister _) (MetaQubitRegister _)) : instructions) = circuitInstruction (instruction : instructions)
defCircuitInstructions (instruction@(CPhase01 (ComplexConstant _) (MetaQubitRegister _) (MetaQubitRegister _)) : instructions) = circuitInstruction (instruction : instructions)
defCircuitInstructions (instruction@(CPhase01 (MetaRegister _) (MetaQubitRegister _) (MetaQubitRegister _)) : instructions) = circuitInstruction (instruction : instructions)

defCircuitInstructions (instruction@(CPhase10 (RealConstant _) (MetaQubitRegister _) (MetaQubitRegister _)) : instructions) = circuitInstruction (instruction : instructions)
defCircuitInstructions (instruction@(CPhase10 (ComplexConstant _) (MetaQubitRegister _) (MetaQubitRegister _)) : instructions) = circuitInstruction (instruction : instructions)
defCircuitInstructions (instruction@(CPhase10 (MetaRegister _) (MetaQubitRegister _) (MetaQubitRegister _)) : instructions) = circuitInstruction (instruction : instructions)

defCircuitInstructions (instruction@(CPhase (RealConstant _) (MetaQubitRegister _) (MetaQubitRegister _)) : instructions) = circuitInstruction (instruction : instructions)
defCircuitInstructions (instruction@(CPhase (ComplexConstant _) (MetaQubitRegister _) (MetaQubitRegister _)) : instructions) = circuitInstruction (instruction : instructions)
defCircuitInstructions (instruction@(CPhase (MetaRegister _) (MetaQubitRegister _) (MetaQubitRegister _)) : instructions) = circuitInstruction (instruction : instructions)

defCircuitInstructions (instruction@(RX (RealConstant _) (MetaQubitRegister _)) : instructions) = circuitInstruction (instruction : instructions)
defCircuitInstructions (instruction@(RX (ComplexConstant _) (MetaQubitRegister _)) : instructions) = circuitInstruction (instruction : instructions)
defCircuitInstructions (instruction@(RX (MetaRegister _) (MetaQubitRegister _)) : instructions) = circuitInstruction (instruction : instructions)

defCircuitInstructions (instruction@(RY (RealConstant _) (MetaQubitRegister _)) : instructions) = circuitInstruction (instruction : instructions)
defCircuitInstructions (instruction@(RY (ComplexConstant _) (MetaQubitRegister _)) : instructions) = circuitInstruction (instruction : instructions)
defCircuitInstructions (instruction@(RY (MetaRegister _) (MetaQubitRegister _)) : instructions) = circuitInstruction (instruction : instructions)

defCircuitInstructions (instruction@(RZ (RealConstant _) (MetaQubitRegister _)) : instructions) = circuitInstruction (instruction : instructions)
defCircuitInstructions (instruction@(RZ (ComplexConstant _) (MetaQubitRegister _)) : instructions) = circuitInstruction (instruction : instructions)
defCircuitInstructions (instruction@(RZ (MetaRegister _) (MetaQubitRegister _)) : instructions) = circuitInstruction (instruction : instructions)

defCircuitInstructions (instruction@(CNot (MetaQubitRegister _) (MetaQubitRegister _)) : instructions) = circuitInstruction (instruction : instructions)
defCircuitInstructions (instruction@(CCNot (MetaQubitRegister _) (MetaQubitRegister _) (MetaQubitRegister _) (MetaQubitRegister _)) : instructions) = circuitInstruction (instruction : instructions)

defCircuitInstructions (instruction@(PSwap (RealConstant _) (MetaQubitRegister _) (MetaQubitRegister _)) : instructions) = circuitInstruction (instruction : instructions)
defCircuitInstructions (instruction@(PSwap (ComplexConstant _) (MetaQubitRegister _) (MetaQubitRegister _)) : instructions) = circuitInstruction (instruction : instructions)
defCircuitInstructions (instruction@(PSwap (MetaRegister _) (MetaQubitRegister _) (MetaQubitRegister _)) : instructions) = circuitInstruction (instruction : instructions)

defCircuitInstructions (instruction@(Swap (MetaQubitRegister _) (MetaQubitRegister _)) : instructions) = circuitInstruction (instruction : instructions)
defCircuitInstructions (instruction@(ISwap (MetaQubitRegister _) (MetaQubitRegister _)) : instructions) = circuitInstruction (instruction : instructions)
defCircuitInstructions (instruction@(CSwap (MetaQubitRegister _) (MetaQubitRegister _) (MetaQubitRegister _) (MetaQubitRegister _)) : instructions) = circuitInstruction (instruction : instructions)
defCircuitInstructions (instruction@(Measure (MetaQubitRegister _)) : instructions) = circuitInstruction (instruction : instructions)
defCircuitInstructions (instruction@(MeasureOut (MetaQubitRegister _) (MetaRegister _)) : instructions) = circuitInstruction (instruction : instructions)
defCircuitInstructions (instruction@(Reset) : instructions) = circuitInstruction (instruction : instructions)
defCircuitInstructions (instruction@(Halt) : instructions) = circuitInstruction (instruction : instructions)
defCircuitInstructions (instruction@(Jump _) : instructions) = circuitInstruction (instruction : instructions)
defCircuitInstructions (instruction@(JumpWhen _ (MetaRegister _)) : instructions) = circuitInstruction (instruction : instructions)
defCircuitInstructions (instruction@(JumpUnless _ (MetaRegister _)) : instructions) = circuitInstruction (instruction : instructions)
defCircuitInstructions (instruction@(Label _) : instructions) = circuitInstruction (instruction : instructions)
defCircuitInstructions (instruction@(Nop) : instructions) = circuitInstruction (instruction : instructions)
defCircuitInstructions (instruction@(IFalse (MetaRegister _)) : instructions) = circuitInstruction (instruction : instructions)
defCircuitInstructions (instruction@(ITrue (MetaRegister _)) : instructions) = circuitInstruction (instruction : instructions)
defCircuitInstructions (instruction@(INot (MetaRegister _)) : instructions) = circuitInstruction (instruction : instructions)
defCircuitInstructions (instruction@(IAnd (MetaRegister _) (MetaRegister _)) : instructions) = circuitInstruction (instruction : instructions)
defCircuitInstructions (instruction@(IOr (MetaRegister _) (MetaRegister _)) : instructions) = circuitInstruction (instruction : instructions)
defCircuitInstructions (instruction@(Move (MetaRegister _) (MetaRegister _)) : instructions) = circuitInstruction (instruction : instructions)
defCircuitInstructions (instruction@(Exchange (MetaRegister _) (MetaRegister _)) : instructions) = circuitInstruction (instruction : instructions)
defCircuitInstructions (instruction@(Pragma _) : instructions) = circuitInstruction (instruction : instructions)
--Since circuits are macros, defining recursive circuits or calling circuits inside circuits is forbidden

--Circuit call
showCallCircuit :: (Floating a, Show a, Ord a) => Circuit a -> [Either Quantum (Classical a)] -> String
showCallCircuit (Circuit name _ _) [] = name
showCallCircuit (Circuit name parameters _) arguments = name ++ callCircuitArguments parameters arguments

callCircuitArguments :: (Floating a, Show a, Ord a) => [Either Quantum (Classical a)] -> [Either Quantum (Classical a)] -> String
callCircuitArguments [] _ = []
callCircuitArguments (Left (MetaQubitRegister _) : parameters) (Left q@(QubitRegister _) : arguments) = " " ++ (show q) ++ callCircuitArguments parameters arguments
callCircuitArguments (Right (RealConstant _) : parameters) (Right c@(RealConstant _) : arguments) = " " ++ (show c) ++ callCircuitArguments parameters arguments
callCircuitArguments (Right (ComplexConstant _) : parameters) (Right c@(ComplexConstant _) : arguments) = " " ++ (show c) ++ callCircuitArguments parameters arguments
callCircuitArguments (Right (MetaRegister _) : parameters) (Right r@(Register _) : arguments) = " " ++ (show r) ++ callCircuitArguments parameters arguments
callCircuitArguments (Right (MetaRegister _) : parameters) (Right r@(Range _ _) : arguments) = " " ++ (show r) ++ callCircuitArguments parameters arguments