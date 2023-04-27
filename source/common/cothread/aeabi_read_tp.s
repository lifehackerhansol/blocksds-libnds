// SPDX-License-Identifier: Zlib
//
// Copyright (c) 2023 Antonio Niño Díaz

#include <nds/asminc.h>
#include <nds/cpu_asm.h>

// __aeabi_read_tp() is used by GCC to get a pointer to the thread local
// storage.
//
// This is a special function that can't clobber any registers other than r0 and
// lr. This is done so that calls to this function are very fast.
//
// For the most part, this function is used from user code, which is normally
// written in Thumb. Also, there is no point in placing this code in ITCM
// because any code located in main RAM will need to call a veneer to jump to
// this routine. It's better to place it in regular RAM.
//
// However, in debug mode, this function has to be in ARM mode so that it can
// access CPSR easily. IRQ handlers have no thread local storage, so the only
// CPU mode allowed to call __aeabi_read_tp() is user mode.

#ifdef NDEBUG

    .thumb

BEGIN_ASM_FUNC __aeabi_read_tp

    ldr     r0, =__tls
    ldr     r0, [r0]
    bx      lr

#else

    .arm

BEGIN_ASM_FUNC __aeabi_read_tp

    // Regular threads run in system mode, user IRQ handlers run in user mode.
    // Thread local storage is only available in regular threads, so only code
    // runing in system mode can access it.
    // TODO: Make this true. Right now all user code runs in system mode.

    mrs     r0, cpsr
    and     r0, r0, #CPSR_MODE_MASK
    cmp     r0, #CPSR_MODE_SYSTEM
    beq     .ok

    // Cause an exception to lock the program.
    //
    // This opcode is defined to be an undefined instruction by the ARM
    // Architecture Reference Manual (ARM DDI 0100I):
    //
    // A3.16.5 Architecturally Undefined Instruction space

    mrs     r0, cpsr // Save CPSR to make it easier for debugging
    .word   0xE7F000F0

.ok:
    ldr     r0, =__tls
    ldr     r0, [r0]
    bx      lr

#endif
