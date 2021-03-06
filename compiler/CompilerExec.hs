module Main where

import Prelude
import Control.Monad
import Control.Monad.State
import System.Environment
import System.IO
import System.IO.Unsafe

import qualified Data.Map as Map

import Parser
import PreCompiler
import Compiler
import ArmInstructions

testARMShow :: IO()
testARMShow = do
  putStrLn $ show $ Add R1 R2 (O2ShReg R1 NoShift)
  putStrLn $ show $ Add R1 R2 (O2ShReg R1 (Shift ShLSL 12))
  putStrLn $ show $ B CondNO "LAB"
  putStrLn $ show $ B CondEQ "LAB"
  putStrLn $ show $ B CondNE "LAB"
  putStrLn $ show $ CMP R1 (O2ShReg R2 NoShift)
  putStrLn $ show $ CMP R1 (O2ShReg R5 (Shift ShLSR 32))
  putStrLn $ show $ CMP R1 (O2ShImm 12)
  putStrLn $ show $ TST R1 (O2ShImm 12)
  putStrLn $ show $ TST R1 (O2ShReg R5 (Shift ShLSR 32))
  putStrLn $ show $ AND R1 R2 (O2ShImm 11)
  putStrLn $ show $ AND R1 R2 (O2ShReg R5 (Shift ShLSR 32))
  putStrLn $ show $ MOV R1 (O2ShImm 99)
  putStrLn $ show $ MOV R1 (O2ShReg R5 (Shift ShLSR 32))
  putStrLn $ show $ LDR R1 R2 (O2ShImm 15) (PreIndex False)
  putStrLn $ show $ LDR R1 R2 (O2ShImm 15) (PreIndex True)
  putStrLn $ show $ LDR R1 R2 (O2ShImm 15) PostIndex
  putStrLn $ show $ LDR R1 R2 (O2ShImm 15) Offset
  putStrLn $ show $ LDR R1 R2 (O2ShReg R5 (Shift ShLSR 32)) (PreIndex False)
  putStrLn $ show $ LDR R1 R2 (O2ShReg R5 (Shift ShLSR 32)) (PreIndex True)
  putStrLn $ show $ LDR R1 R2 (O2ShReg R5 (Shift ShLSR 32)) PostIndex
  putStrLn $ show $ LDR R1 R2 (O2ShReg R5 (Shift ShLSR 32)) Offset
  -- Load Multiple
  putStrLn $ show $ LDM IA SP False [R1, R2, R3]
  putStrLn $ show $ LDM IB R9 True [R1, R2, R3, R4]
  -- Save Multiple
  putStrLn $ show $ STM DA SP False [R1, R2, R3]
  putStrLn $ show $ STM DB R9 True [R1, R2, R3, R4]
  -- Comment
  putStrLn $ show $ Comment "Test comment!!!"


-- main running function
main :: IO()
main = do
  -- testARMShow
  args <- getArgs
  let fileName = args !! 0
  compileFile fileName
