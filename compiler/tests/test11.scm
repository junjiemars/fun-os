(comment "global constants")
(comment "interrups start")
(inline "REG_IME: .word 0x04000208")
(inline "REG_IE: .word 0x04000210")
(inline "REG_IF: .word 0x04000214")
(inline "REG_TM0_DAT: .word 0x04000100")
(inline "REG_TM0_CNT: .word 0x04000102")
(inline "INT_HAND_SHIFT: .word 0x3ffc")
(inline "INTERR_HANDLER: .word 0x0b003ffc")
(inline "TM0_EN: .word 0b11000011")
(comment "interrups end")
(comment "stack size for a process")
(inline "DATA_START: .word 0x0b000000")
(inline "STACK_SIZE: .word 15360")

(comment "declarations of C functions")
(c-fun print-int void (int))
(c-fun print-bool void (bool))

(comment "declarations of global functions")
(global-fun scheme-entry)

(assembler (scheme-entry mem_addr mem_size)
  (comment "prologue start")
  (STMFD SP!, {LR})
  (STMFD SP!, {R4, R5, R6, R7, R8, R9})
  (STMFD SP!, {SL})
  (STMFD SP!, {FP})
  (MOV FP, SP)
  (comment "prologue end")

  (comment "all necessary data kept in dtcm")
  (LDR SL, DATA_START)

  (comment "setting stack beginning to SP")
  (MOV SP, R0)
  (ADD SP, SP, R1)
  (comment "setting heap beginning to SL")
  (STR R0, [SL])

  (comment "processes")
  (BL initialize_processes)

  (comment "interrupts")
  (BL initialize_interrupts)

  (MOV R0, #-33)
  (BL print_int)
  (MOV R0, PC)
  (BL print_int)
  (MOV R0, #-33)
  (BL print_int)
  (MOV R0, SP)
  (BL print_int)
  (MOV R0, #0)
  (MOV R1, #1)
  (MOV R2, #2)
  (MOV R3, #3)
  (MOV R4, #4)
  (MOV R5, #5)
  (MOV R6, #6)
  (MOV R7, #7)
  (MOV R8, #8)
  (MOV R9, #9)
  (MOV R12, #12)
  (loop1:)
  (B loop1)

  (comment "run code")
  (BL internal_scheme_entry)

  (comment "epilog start")
  (MOV SP, FP)
  (LDMFD SP!, {FP})
  (LDMFD SP!, {SL})
  (LDMFD SP!, {R4, R5, R6, R7, R8, R9})
  (LDMFD SP!, {LR})
  (BX LR)
  (comment "epilog end"))


(assembler (initialize-processes)
  (comment "prologue start")
  (STMFD SP!, {LR})
  (STMFD SP!, {R4, R5, R6, R7, R8, R9})
  (STMFD SP!, {SL})
  (STMFD SP!, {FP})
  (MOV FP, SP)
  (comment "prologue end")

  (comment "there are no processes running")
  (MOV R0, #0)
  (STR R0, [SL, #4])
  (comment "active process no")
  (MOV R0, #-1)
  (STR R0, [SL, #8])

  (comment "set active proc list to all -1")
  (MOV R0, SL)
  (ADD R0, R0, #8)
  (MOV R2, #-1)
  (MOV R1, #1)
  (MOV R3, #4)
  (active_proc_loop:)
  (CMP R1, #100)
  (BGT active_proc_end)
  (STR R2, [R0, R3])
  (ADD R1, R1, #1)
  (ADD R3, R3, #4)
  (B active_proc_loop)
  (active_proc_end:)

  (comment "add idle process")
  (ADR R0, idle_process)
  (BL add_process)

  (comment "start idle process")
  (comment "idle proc number in R0")
  (comment "add idle process")
  (ADR R0, idle_process)
  (BL add_process)

  (comment "start idle process")
  (comment "idle proc number in R0")
  (BL enable_process)

  (comment "epilog start")
  (MOV SP, FP)
  (LDMFD SP!, {FP})
  (LDMFD SP!, {SL})
  (LDMFD SP!, {R4, R5, R6, R7, R8, R9})
  (LDMFD SP!, {LR})
  (BX LR)
  (comment "epilog end"))

(assembler (enable-process proc-no)
  (comment "prologue start")
  (STMFD SP!, {LR})
  (STMFD SP!, {R4, R5, R6, R7, R8, R9})
  (STMFD SP!, {SL})
  (STMFD SP!, {FP})
  (MOV FP, SP)
  (comment "prologue end")

  (comment "change state to waiting")
  (comment "set R1 to Waiting")
  (MOV R1, #2)
  (comment "tag int")
  (LSL R1, #3)
  (ORR R1, R1, #2)
  (BL change_process_state)

  (comment "epilog start")
  (MOV SP, FP)
  (LDMFD SP!, {FP})
  (LDMFD SP!, {SL})
  (LDMFD SP!, {R4, R5, R6, R7, R8, R9})
  (LDMFD SP!, {LR})
  (BX LR)
  (comment "epilog end"))

(assembler (disable-process proc-no)
  (comment "prologue start")
  (STMFD SP!, {LR})
  (STMFD SP!, {R4, R5, R6, R7, R8, R9})
  (STMFD SP!, {SL})
  (STMFD SP!, {FP})
  (MOV FP, SP)
  (comment "prologue end")

  (comment "change state to Blocked")
  (comment "set R1 to Blocked")
  (MOV R1, #3)
  (comment "tag int")
  (LSL R1, #3)
  (ORR R1, R1, #2)
  (BL change_process_state)

  (comment "epilog start")
  (MOV SP, FP)
  (LDMFD SP!, {FP})
  (LDMFD SP!, {SL})
  (LDMFD SP!, {R4, R5, R6, R7, R8, R9})
  (LDMFD SP!, {LR})
  (BX LR)
  (comment "epilog end"))

(assembler (change-process-state proc-no new-state)
  (comment "prologue start")
  (STMFD SP!, {LR})
  (STMFD SP!, {R4, R5, R6, R7, R8, R9})
  (STMFD SP!, {SL})
  (STMFD SP!, {FP})
  (MOV FP, SP)
  (comment "prologue end")

  (comment "copy proc no")
  (MOV R9, R0)
  (comment "copy state")
  (MOV R8, R1)
  (comment "untag int")
  (LSR R8, #3)

  (comment "find a PCB block")
  (MOV R0, SL)
  (ADD R0, R0, #8)
  (MOV R1, #1)
  (MOV R3, #4)
  (proc_pcb_loop:)
  (MUL R4, R1, R3)
  (LDR R2, [R0, R4])
  (CMP R2, R9)
  (BEQ proc_pcb_found)
  (ADD R1, R1, #1)
  (B proc_pcb_loop)
  (proc_pcb_found:)

  (comment "set PCB block")
  (MOV R0, SL)
  (ADD R0, R0, #408)
  (SUB R7, R1, #1)
  (MOV R3, #84)
  (MUL R6, R7, R3)
  (ADD R0, R0, R6)

  (comment "setting proc state")
  (comment "proc state, 1 - Running, 2 - Waiting, 3 - Blocked")
  (STR R8, [R0, #16])

  (comment "epilog start")
  (MOV SP, FP)
  (LDMFD SP!, {FP})
  (LDMFD SP!, {SL})
  (LDMFD SP!, {R4, R5, R6, R7, R8, R9})
  (LDMFD SP!, {LR})
  (BX LR)
  (comment "epilog end"))

(assembler (add-process proc)
  (comment "prologue start")
  (STMFD SP!, {LR})
  (STMFD SP!, {R4, R5, R6, R7, R8, R9})
  (STMFD SP!, {SL})
  (STMFD SP!, {FP})
  (MOV FP, SP)
  (comment "prologue end")

  (comment "save proc addr")
  (MOV R9, R0)

  (comment "ERROR: - FIX THIS")
  (comment "ERROR: problem when > 100 processes")
  (comment "find a free PCB block")
  (MOV R0, SL)
  (ADD R0, R0, #8)
  (MOV R1, #1)
  (MOV R3, #4)
  (free_proc_pcb_loop:)
  (MUL R4, R1, R3)
  (LDR R2, [R0, R4])
  (CMP R2, #-1)
  (BEQ free_proc_pcb_found)
  (ADD R1, R1, #1)
  (B free_proc_pcb_loop)
  (free_proc_pcb_found:)
  (free_proc_pcb_end:)

  (comment "get a new process no")
  (LDR R5, [SL, #4])
  (comment "untag int")
  (LSR R5, #3)
  (comment "increase")
  (ADD R5, R5, #1)
  (comment "tag int")
  (LSL R5, #3)
  (ORR R5, R5, #2)

  (comment "set a proc count")
  (STR R5, [SL, #4])

  (comment "set a new process block no")
  (STR R5, [R0, R4])

  (comment "set PCB block")
  (MOV R0, SL)
  (ADD R0, R0, #408)
  (SUB R8, R1, #1)
  (MOV R3, #84)
  (MUL R6, R8, R3)
  (ADD R0, R0, R6)

  (comment "setting")
  (comment "proc no")
  (STR R5, [R0, #4])
  (comment "proc priority")
  (MOV R2, #1)
  (STR R2, [R0, #8])
  (comment "proc address")
  (STR R9, [R0, #12])
  (comment "proc state, 1 - Running, 2 - Waiting, 3 - Blocked")
  (MOV R2, #3)
  (comment "tag int")
  (LSL R2, #3)
  (ORR R2, R2, #2)
  (STR R2, [R0, #16])
  (comment "CPSR - System mode")
  (MOV R2, #0b11111)
  (STR R2, [R0, #20])

  (comment "reg block")
  (ADD R0, R0, #20)
  (comment "SL reg")
  (STR SL, [R0, #44])
  (comment "SP reg")
  (LDR R7, [SL])
  (LDR R6, STACK_SIZE)
  (MUL R6, R1, R6)
  (ADD R6, R6, R7)
  (STR R6, [R0, #56])
  (comment "PC reg")
  (ADD R8, R9, #4)
  (STR R8, [R0, #64])
  (comment "other regs not set")

  (comment "return proc no")
  (MOV R0, R5)

  (comment "epilog start")
  (MOV SP, FP)
  (LDMFD SP!, {FP})
  (LDMFD SP!, {SL})
  (LDMFD SP!, {R4, R5, R6, R7, R8, R9})
  (LDMFD SP!, {LR})
  (BX LR)
  (comment "epilog end"))

(assembler (remove-process proc-no)
  (comment "prologue start")
  (STMFD SP!, {LR})
  (STMFD SP!, {R4, R5, R6, R7, R8, R9})
  (STMFD SP!, {SL})
  (STMFD SP!, {FP})
  (MOV FP, SP)
  (comment "prologue end")

  (comment "copy proc no")
  (MOV R9, R0)

  (comment "find a PCB block")
  (MOV R0, SL)
  (ADD R0, R0, #8)
  (MOV R1, #1)
  (MOV R3, #4)
  (rem_proc_pcb_loop:)
  (MUL R4, R1, R3)
  (LDR R2, [R0, R4])
  (CMP R2, R9)
  (BEQ rem_proc_pcb_found)
  (ADD R1, R1, #1)
  (B rem_proc_pcb_loop)
  (rem_proc_pcb_found:)

  (comment "update process no")
  (LDR R5, [SL, #4])
  (comment "untag int")
  (LSR R5, #3)
  (comment "decrease")
  (SUB R5, R5, #1)
  (comment "tag int")
  (LSL R5, #3)
  (ORR R5, R5, #2)
  (STR R5, [SL, #4])

  (comment "free PCB block")
  (MOV R2, #-1)
  (STR R2, [R0, R4])

  (comment "epilog start")
  (MOV SP, FP)
  (LDMFD SP!, {FP})
  (LDMFD SP!, {SL})
  (LDMFD SP!, {R4, R5, R6, R7, R8, R9})
  (LDMFD SP!, {LR})
  (BX LR)
  (comment "epilog end"))

(assembler (idle-process)

  (MOV R0, #0)
  (MOV R1, #10)
  (MOV R2, #20)
  (MOV R3, #30)
  (MOV R4, #40)
  (MOV R5, #50)
  (MOV R6, #60)
  (MOV R7, #70)
  (MOV R8, #80)
  (MOV R9, #90)
  (MOV R12, #120)

  (idle_inf_loop:)
  (B idle_inf_loop)

  (comment "process end"))

(assembler (idle-process-2)

  (MOV R0, #0)
  (MOV R1, #11)
  (MOV R2, #21)
  (MOV R3, #31)
  (MOV R4, #41)
  (MOV R5, #51)
  (MOV R6, #61)
  (MOV R7, #71)
  (MOV R8, #81)
  (MOV R9, #91)
  (MOV R12, #121)

  (idle_2_inf_loop:)
  (B idle_2_inf_loop)

  (comment "process end"))

(assembler (initialize-interrupts)
  (comment "prologue start")
  (STMFD SP!, {LR})
  (STMFD SP!, {R4, R5, R6, R7, R8, R9})
  (STMFD SP!, {SL})
  (STMFD SP!, {FP})
  (MOV FP, SP)
  (comment "prologue end")

  (comment "interrupt start")
  (comment "disable interrupts, REG_IME = 0")
  (LDR R5, REG_IME)
  (MOV R6, #0)
  (STR R6, [R5])

  (comment "set TM0 value")
  (LDR R5, REG_TM0_DAT)
  (MOV R6, #0)
  (STRH R6, [R5])

  (comment "set TM0 control")
  (comment "enabled, irq, prescale 1024")
  (LDR R5, REG_TM0_CNT)
  (LDR R6, TM0_EN)
  (STRh R6, [R5])

  (comment "enable TM0")
  (LDR R5, REG_IE)
  (LDR R6, [R5])
  (ORR R6, R6, #0b1000)
  (MOV R6, #0b1000)
  (STR R6, [R5])

  (comment "set interrupt handler")
  (LDR R5, INTERR_HANDLER)
  (ADR R6, interrupt_handler)
  (STR R6, [R5])

  (comment "enable interrupts, REG_IME = 1")
  (LDR R5, REG_IME)
  (MOV R6, #0b1)
  (STR R6, [R5])
  (comment "interrupt end")

  (comment "epilog start")
  (MOV SP, FP)
  (LDMFD SP!, {FP})
  (LDMFD SP!, {SL})
  (LDMFD SP!, {R4, R5, R6, R7, R8, R9})
  (LDMFD SP!, {LR})
  (BX LR)
  (comment "epilog end"))

(assembler (interrupt-handler)
  (comment "prologue start")
  (STMFD SP!, {LR})
  (STMFD SP!, {R4, R5, R6, R7, R8, R9})
  (STMFD SP!, {SL})
  (STMFD SP!, {FP})
  (MOV FP, SP)
  (comment "prologue end")

  (LDR R5, REG_IF)
  (LDR R6, [R5])

  (vblank:)
  (MOV R7, R6)
  (AND R7, R7, #0b0001)
  (CMP R7, #0b0001)
  (BNE timer)
  (MOV R8, #0b0001)

  (timer:)
  (MOV R7, R6)
  (AND R7, R7, #0b1000)
  (CMP R7, #0b1000)
  (BNE end)
  (ORR R8, R8, #0b1000)

  (comment "low level operations")
  (comment "reg r0-r3 not used later")
  (comment "don't need to be saved on the stack")

  (comment "select process no to run")
  (comment "process no in R0")
  (MOV R0, #199)
  (BL print_int)
  (BL select_process)
  (MOV R9, R0)
  (BL print_int)
  (MOV R0, R9)
  (BL run_process)

  (end:)
  (STR R8, [R5])

  (comment "epilog start")
  (MOV SP, FP)
  (LDMFD SP!, {FP})
  (LDMFD SP!, {SL})
  (LDMFD SP!, {R4, R5, R6, R7, R8, R9})
  (LDMFD SP!, {LR})
  (BX LR)
  (comment "epilog end"))
  
(assembler (run-process no)
  (comment "it is called from interrupt handler")

  (comment "copy active process to PCB block")
  (LDR R4, [SL, #8])
  (CMP R4, #-1)
  (comment "no active process, just load a new process")
  (BEQ run_process_load_proc)

  (comment "find active proc PCB block")
  (ADD R1, SL, #8)
  (MOV R2, #0)
  (run_proc_active_pcb_find:)
  (ADD R1, R1, #4)
  (ADD R2, R2, #1)
  (LDR R3, [R1])
  (CMP R4, R3)
  (BEQ run_proc_active_pcb_found)
  (B run_proc_active_pcb_find)

  (run_proc_active_pcb_found:)
  (comment "active pcb found")

  (SUB R2, R2, #1)
  (MOV R3, #84)
  (MUL R1, R2, R3)
  (ADD R2, SL, #428)
  (ADD R2, R1, R2)
  (comment "R2 points to CPSR positionin PCB")

  (comment "save active process to pcb")
  (comment "state -> Waiting")
  (MOV R1, #2)
  (comment "tag int")
  (LSL R1, #3)
  (ORR R1, R1, #2)
  (STR R1, [R2, #-4])
  (comment "CPSR")
  (MRS R1, SPSR)
  (STR R1, [R2])
  (comment "R0")
  (LDR R1, [SP, #36])
  (STR R1, [R2, #4])
  (comment "R1")
  (LDR R1, [SP, #40])
  (STR R1, [R2, #8])
  (comment "R2")
  (LDR R1, [SP, #44])
  (STR R1, [R2, #12])
  (comment "R3")
  (LDR R1, [SP, #48])
  (STR R1, [R2, #16])
  (comment "R4")
  (LDR R1, [SP, #8])
  (STR R1, [R2, #20])
  (comment "R5")
  (LDR R1, [SP, #12])
  (STR R1, [R2, #24])
  (comment "R6")
  (LDR R1, [SP, #16])
  (STR R1, [R2, #28])
  (comment "R7")
  (LDR R1, [SP, #20])
  (STR R1, [R2, #32])
  (comment "R8")
  (LDR R1, [SP, #24])
  (STR R1, [R2, #36])
  (comment "R9")
  (LDR R1, [SP, #28])
  (STR R1, [R2, #40])

  (comment "starting from R10 special registers")

  (comment "R10 - SL")
  (LDR R1, [SP, #4])
  (STR R1, [R2, #44])

  (comment "R11 - FP")
  (LDR R1, [SP])
  (STR R1, [R2, #48])

  (comment "R12 - IP")
  (LDR R1, [SP, #52])
  (STR R1, [R2, #52])

  (comment "R13 - SP")
  (comment "go back to SYSTEM mode")
  (comment "to access process SP")
  (MRS R3, CPSR)
  (ORR R1, R3, #0b11111)
  (MSR CPSR, R1)
  (MOV R1, SP)
  (MSR CPSR, R3)
  (STR R1, [R2, #56])

  (comment "R14 - LR")
  (MRS R3, CPSR)
  (ORR R1, R3, #0b11111)
  (MSR CPSR, R1)
  (MOV R1, LR)
  (MSR CPSR, R3)
  (STR R1, [R2, #60])

  (comment "R15 - PC")
  (LDR R1, [SP, #56])
  (STR R1, [R2, #64])


  (run_process_load_proc:)
  (comment "find new proc PCB block")

  (ADD R1, SL, #8)
  (MOV R2, #0)
  (run_proc_new_pcb_find:)
  (ADD R1, R1, #4)
  (ADD R2, R2, #1)
  (LDR R3, [R1])
  (CMP R0, R3)
  (BEQ run_proc_new_pcb_found)
  (B run_proc_new_pcb_find)

  (run_proc_new_pcb_found:)
  (comment "new pcb found")

  (SUB R2, R2, #1)
  (MOV R3, #84)
  (MUL R1, R2, R3)
  (ADD R2, SL, #428)
  (ADD R2, R1, R2)
  (comment "R2 points to CPSR positionin PCB")

  (comment "load new process from pcb")
  (comment "state -> Running")
  (MOV R1, #1)
  (comment "tag int")
  (LSL R1, #3)
  (ORR R1, R1, #2)
  (STR R1, [R2, #-4])
  (comment "CPSR")
  (LDR R1, [R2])
  (MSR SPSR, R1)
  (comment "R0")
  (LDR R1, [R2, #4])
  (STR R1, [SP, #36])
  (comment "R1")
  (LDR R1, [R2, #8])
  (STR R1, [SP, #40])
  (comment "R2")
  (LDR R1, [R2, #12])
  (STR R1, [SP, #44])
  (comment "R3")
  (LDR R1, [R2, #16])
  (STR R1, [SP, #48])
  (comment "R4")
  (LDR R1, [R2, #20])
  (STR R1, [SP, #8])
  (comment "R5")
  (LDR R1, [R2, #24])
  (STR R1, [SP, #12])
  (comment "R6")
  (LDR R1, [R2, #28])
  (STR R1, [SP, #16])
  (comment "R7")
  (LDR R1, [R2, #32])
  (STR R1, [SP, #20])
  (comment "R8")
  (LDR R1, [R2, #36])
  (STR R1, [SP, #24])
  (comment "R9")
  (LDR R1, [R2, #40])
  (STR R1, [SP, #28])

  (comment "starting from R10 special registers")

  (comment "R10 - SL")
  (LDR R1, [R2, #44])
  (STR R1, [SP, #4])

  (comment "R11 - FP")
  (LDR R1, [R2, #48])
  (STR R1, [SP])

  (comment "R12 - IP")
  (LDR R1, [R2, #52])
  (STR R1, [SP, #52])

  (comment "R13 - SP")
  (comment "go back to SYSTEM mode")
  (comment "to set process SP")
  (MRS R3, CPSR)
  (ORR R1, R3, #0b11111)
  (MSR CPSR, R1)
  (LDR R1, [R2, #56])
  (MOV SP, R1)
  (MSR CPSR, R3)

  (comment "R14 - LR")
  (MRS R3, CPSR)
  (ORR R1, R3, #0b11111)
  (MSR CPSR, R1)
  (LDR R1, [R2, #60])
  (MOV LR, R1)
  (MSR CPSR, R3)

  (comment "R15 - PC")
  (LDR R1, [R2, #64])
  (STR R1, [SP, #56])

  (comment "set active process no")
  (STR R0, [SL, #8])
  (run_proc_end:))

(assembler (select-process)
  (comment "it is called from interrupt handler")

  (comment "prologue start")
  (STMFD SP!, {LR})
  (STMFD SP!, {R4, R5, R6, R7, R8, R9})
  (STMFD SP!, {SL})
  (STMFD SP!, {FP})
  (MOV FP, SP)
  (comment "prologue end")

  (comment "check if there is a running process")
  (LDR R0, [SL, #8])
  (CMP R0, #-1)
  (BEQ sele_proc_sel_no_running)

  (sele_proc_sel_is_running:)
  (comment "find proc PCB block")
  (ADD R1, SL, #8)
  (MOV R2, #0)
  (sele_proc_sel_find:)
  (ADD R1, R1, #4)
  (ADD R2, R2, #1)
  (LDR R3, [R1])
  (CMP R0, R3)
  (BEQ sele_proc_next_find)
  (B sele_proc_sel_find)

  (sele_proc_sel_no_running:)
  (ADD R1, SL, #8)
  (MOV R2, #0)

  (sele_proc_next_find:)
  (comment "current process PCB found")
  (comment "find next waiting process")
  (ADD R1, R1, #4)
  (ADD R2, R2, #1)
  (CMP R2, #100)
  (BGT sele_proc_next_not_found)
  (LDR R3, [R1])
  (CMP R3, #-1)

  (BEQ sele_proc_next_find)
  (comment "we have PCB block")
  (comment "check if a state of the process is waiting")
  (comment "get PCB block")
  (ADD R4, SL, #408)
  (SUB R5, R2, #1)
  (MOV R3, #84)
  (MUL R6, R5, R3)
  (ADD R4, R4, R6)
  (LDR R7, [R4, #16])
  (MOV R8, #3)
  (comment "tag int")
  (LSL R8, #3)
  (ORR R8, R8, #2)
  (CMP R7, R8)
  (BNE sele_proc_next_found)
  (B sele_proc_next_find)

  (sele_proc_next_not_found:)
  (comment "did not find any process")
  (comment "start searching from the beginning")
  (B sele_proc_sel_no_running)

  (sele_proc_next_found:)
  (LDR R0, [R4, #4])

  (comment "epilog start")
  (MOV SP, FP)
  (LDMFD SP!, {FP})
  (LDMFD SP!, {SL})
  (LDMFD SP!, {R4, R5, R6, R7, R8, R9})
  (LDMFD SP!, {LR})
  (BX LR)
  (comment "epilog end"))

(assembler (alloc-mem mem_size)
  (comment "allocates specified memory size on the heap")
  (comment "8-byte borders")
  (LDR R1, [SL])
  (AND R2, R1, #0b111)
  (CMP R2, #0)
  (BEQ .alloc_alligned)
  (comment "need to align to nearest boundary")
  (AND R1, R1, #0xFFFFFFF8)
  (ADD R1, R1, #0b1000)
  (.alloc_alligned:)
  (comment "heap pointer is aligned")
  (MOV R3, R1)
  (comment "move heap pointer")
  (comment "untag int")
  (LSR R0, #3)
  (ADD R1, R1, R0)
  (STR R1, [SL])
  (comment "return")
  (MOV R0, R3)
  (BX LR))

(comment "vector")

(assembler (make-vector len)
  (comment "constructs a vector")
  (comment "prologue start")
  (STMFD SP!, {LR})
  (STMFD SP!, {R4, R5, R6, R7, R8, R9})
  (STMFD SP!, {SL})
  (STMFD SP!, {FP})
  (MOV FP, SP)
  (comment "prologue end")
  (comment "allocate memory, (4 + 4 * len) bytes")
  (MOV R4, R0)
  (comment "untag int")
  (LSR R0, #3)
  (ADD R0, R0, #1)
  (MOV R2, #4)
  (MOV R3, R0)
  (MUL R0, R3, R2)
  (comment "tag int")
  (LSL R0, #3)
  (ORR R0, R0, #2)
  (BL alloc_mem)
  (comment "set length")
  (STR R4, [R0])
  (comment "tag")
  (ADD R0, R0, #0b101)
  (comment "return")
  (comment "epilog start")
  (MOV SP, FP)
  (LDMFD SP!, {FP})
  (LDMFD SP!, {SL})
  (LDMFD SP!, {R4, R5, R6, R7, R8, R9})
  (LDMFD SP!, {LR})
  (BX LR)
  (comment "epilog end"))

(assembler (vector-ref v k)
  (comment "returns element of a vector")
  (comment "prologue start")
  (STMFD SP!, {LR})
  (STMFD SP!, {R4, R5, R6, R7, R8, R9})
  (STMFD SP!, {SL})
  (STMFD SP!, {FP})
  (MOV FP, SP)
  (comment "prologue end")
  (comment "untag v")
  (AND R3, R0, #0xFFFFFFF8)
  (comment "untag int k")
  (LSR R1, #3)
  (comment "get")
  (MOV R4, #4)
  (ADD R5, R1, #1)
  (MUL R6, R4, R5)
  (ADD R3, R3, R6)
  (LDR R0, [R3])
  (comment "return")
  (comment "epilog start")
  (MOV SP, FP)
  (LDMFD SP!, {FP})
  (LDMFD SP!, {SL})
  (LDMFD SP!, {R4, R5, R6, R7, R8, R9})
  (LDMFD SP!, {LR})
  (BX LR)
  (comment "epilog end"))


(assembler (vector-set! v k obj)
  (comment "sets element of a vector")
  (comment "prologue start")
  (STMFD SP!, {LR})
  (STMFD SP!, {R4, R5, R6, R7, R8, R9})
  (STMFD SP!, {SL})
  (STMFD SP!, {FP})
  (MOV FP, SP)
  (comment "prologue end")
  (comment "untag v")
  (AND R3, R0, #0xFFFFFFF8)
  (comment "untag int k")
  (LSR R1, #3)
  (comment "set")
  (MOV R4, #4)
  (ADD R5, R1, #1)
  (MUL R6, R4, R5)
  (ADD R3, R3, R6)
  (STR R2, [R3])
  (comment "return")
  (comment "epilog start")
  (MOV SP, FP)
  (LDMFD SP!, {FP})
  (LDMFD SP!, {SL})
  (LDMFD SP!, {R4, R5, R6, R7, R8, R9})
  (LDMFD SP!, {LR})
  (BX LR)
  (comment "epilog end"))


(assembler (vector-length v)
  (comment "returns length of a vector")
  (comment "untag")
  (AND R0, R0, #0xFFFFFFF8)
  (comment "return")
  (LDR R0, [R0])
  (BX LR))


(assembler (vector? v)
  (comment "checks if x is a vector")
  (comment "vector has a mask 111")
  (comment "vector has a tag 001")
  (AND R0, R0, #0b111)
  (CMP R0, #0b101)
  (MOVEQ R0, #12)
  (MOVNE R0, #4)
  (BX LR))


(comment "cons")

(assembler (cons c1 c2)
  (comment "constructs cons")
  (comment "prologue start")
  (STMFD SP!, {LR})
  (STMFD SP!, {R4, R5, R6, R7, R8, R9})
  (STMFD SP!, {SL})
  (STMFD SP!, {FP})
  (MOV FP, SP)
  (comment "prologue end")
  (comment "allocate memory, 8 bytes")
  (MOV R4, R0)
  (MOV R5, R1)
  (MOV R0, #8)
  (comment "tag int")
  (LSL R0, #3)
  (ORR R0, R0, #2)
  (BL alloc_mem)
  (MOV R6, R0)
  (comment "set car")
  (STR R4, [R6])
  (comment "set cdr")
  (ADD R6, R6, #4)
  (STR R5, [R6])
  (comment "tag")
  (ADD R0, R0, #0b001)
  (comment "return")
  (comment "epilog start")
  (MOV SP, FP)
  (LDMFD SP!, {FP})
  (LDMFD SP!, {SL})
  (LDMFD SP!, {R4, R5, R6, R7, R8, R9})
  (LDMFD SP!, {LR})
  (BX LR)
  (comment "epilog end"))

(assembler (pair? a)
  (comment "checks if x is a pair")
  (comment "pair has a mask 111")
  (comment "pair has a tag 001")
  (AND R0, R0, #0b111)
  (CMP R0, #0b001)
  (MOVEQ R0, #12)
  (MOVNE R0, #4)
  (BX LR))

(assembler (car c)
  (comment "returns car of cons")
  (comment "untag")
  (AND R0, R0, #0xFFFFFFF8)
  (comment "return")
  (LDR R0, [R0])
  (BX LR))

(assembler (cdr c)
  (comment "returns cdr of cons")
  (comment "untag")
  (AND R0, R0, #0xFFFFFFF8)
  (comment "return")
  (ADD R0, R0, #4)
  (LDR R0, [R0])
  (BX LR))

(define (internal-scheme-entry)
  (test-vector-comp))

(define (test-vector-comp)
  (let ((v (vector 1 (vector 10 20) (+ 2 3))))
    (begin  (print-int (vector-ref v 0))
            (print-int (vector-ref (vector-ref v 1) 0))
            (print-int (vector-ref v 2)))))

(define (test-vector-literal)
  (let ((v (vector 1 2 3 4 5)))
    (begin  (print-int (vector-ref v 0))
            (print-int (vector-ref v 1))
            (print-int (vector-ref v 2))
            (print-int (vector-ref v 3))
            (print-int (vector-ref v 4)))))

(define (test-vector-simp)
  (let ((v (begin (comment "vector construct")
                  (let ((vec01 (make-vector 4)))
                    (begin (vector-set! vec01 0 3) vec01)))))
    (print-int (vector-ref vec01 0))))

(define (test-list-exp-2)
  (let ((ls (list 1 (list 10 20) 3)))
    (print-int (car (cdr (car (cdr ls)))))))

(define (test-list-exp)
  (let ((ls (list 1 2 3)))
    (print-int (cdr (cdr (cdr ls))))))

(define (test-cons-complex)
  (let ((ls (cons 1 (cons 2 3))))
    (print-int (cdr (cdr ls)))))


(define (test-let-2)
  (let ((v1 (make-vector 4)) (v2 (make-vector 5)))
    (begin 
      (vector-set! v1 0 0)
      (vector-set! v1 1 1)
      (vector-set! v1 2 2)
      (vector-set! v1 3 3)
      (vector-set! v2 0 10)
      (vector-set! v2 1 20)
      (vector-set! v2 2 30)
      (vector-set! v2 3 40)
      (+ (vector-ref v1 3) (vector-ref v2 2)))))

(define (test-let)
  (let ((a 1) (b 5))
    (+ a b)))

(define (test-vector-init)
    (test-vector (make-vector 10) (cons 99 9) (make-vector 5)))

(define (test-vector v1 co v2)
  (begin
    (print-int (car co))
    (vector-set! v1 6 1)
    (vector-set! v1 7 2)
    (vector-set! v1 8 3)
    (vector-set! v1 9 4)
    (vector-set! v2 0 10)
    (vector-set! v2 1 20)
    (vector-set! v2 2 30)
    (vector-set! v2 3 40)
    (print-int (cdr co))
    (print-int (vector-ref v1 6))
    (print-int (vector-ref v1 7))
    (print-int (vector-ref v1 8))
    (print-int (vector-ref v1 9))
    (print-int (vector-ref v2 0))
    (print-int (vector-ref v2 1))
    (print-int (vector-ref v2 2))
    (print-int (vector-ref v2 3))))

(define (test-cons-init)
  (test-cons (cons 1 2) (cons 3 4) (cons 5 6) (cons 7 8)))

(define (test-cons a b c d)
  (begin
  (print-int (car a))
  (print-int (cdr a))
  (print-int (car b))
  (print-int (cdr b))
  (print-int (car c))
  (print-int (cdr c))
  (print-int (car d))
  (print-int (cdr d))))

(define (test-cons-2-init)
  (begin 
    (print-int (car (cons 1 2)))
    (print-int (car (cons 10 20)))
    (print-int (car (cons 11 21)))
    (print-int (car (cons 12 22)))
    (print-int (car (cons 13 23)))
    (print-int (car (cons 5 6)))))


(comment "dtcm section has 16KB")
(comment "One fun frame takes 52 bytes = 13 variables * 4 bytes")
(comment "the function is called 242 times, the whole stack is 12584 bytes")
(define (dtcm-stack-size i)
  (begin (print-int i) (dtcm-stack-size (+ i 1))))


(define (power6 i)
  (if (<= i 1)
    1
    (begin (print-int i) (power (- i 1)))))

(define (power i)
  (if (<= i 1)
    1
    (begin (print-int i) (* i (power (- i 1))))))

(define (poweri i)
  5)

(define (power2 i)
  (cond ((<= i 1) 1)
        (else (* i (power (- i 1))))))

(define (scheme_entry2)
  (cond ((< 2 1) 1)
        ((eq? 3 2) 2)
        (else (print_bool #f))))

(define (print i)
  (cond (#f 10)
        (#t (cond (#f 11)
                  (#t (print_int 32))
                  (#t (print 1))
                  (#t (print 1 2))
                  (#t (print_bool #t))
                  (#t (cond (#f 13)
                            (#t (begin 100 (+ 30 (+ 30 (+ 30 (+ 30 30))))))))))))

(comment "ret 15")




(comment "ASSEMBLER")

(comment "EQUALITY")

(assembler (eq? a b)
  (comment "equality, compares addresses")
  (comment "implemented incorrectly")
  (CMP R0, R1)
  (MOVEQ R0, #12)
  (MOVNE R0, #4)
  (BX LR))




(comment "Atom types predicates")

(assembler (atom? a)
  (comment "checks if x is an atom")
  (comment "number has mask 00001")
  (comment "number has tag 00000")
  (AND R0, R0, #1)
  (CMP R0, #0)
  (MOVEQ R0, #12)
  (MOVNE R0, #4)
  (BX LR))


(assembler (number? x)
  (comment "checks if x is a number")
  (comment "number has mask 00111")
  (comment "number has tag 00010")
  (AND R0, R0, #7)
  (CMP R0, #2)
  (MOVEQ R0, #12)
  (MOVNE R0, #4)
  (BX LR))

(assembler (boolean? x)
  (comment "checks if x is boolean")
  (comment "number has mask 00111")
  (comment "number has tag 00100")
  (AND R0, R0, #7)
  (CMP R0, #4)
  (MOVEQ R0, #12)
  (MOVNE R0, #4)
  (BX LR))


(comment "Reference types predicates")

(assembler (reference? a)
  (comment "checks if x is reference")
  (comment "number has mask 00001")
  (comment "number has tag 00001")
  (AND R0, R0, #1)
  (CMP R0, #1)
  (MOVEQ R0, #12)
  (MOVNE R0, #4)
  (BX LR))
