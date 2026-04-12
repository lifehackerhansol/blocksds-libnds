// SPDX-License-Identifier: Zlib
// SPDX-FileNotice: Modified from the original version by the BlocksDS project.
//
// Copyright (C) 2009 Dave Murphy (WinterMute)
// Copyright (C) 2023 Antonio Niño Díaz

#include <nds/asminc.h>

    .syntax  unified
#ifdef ARM9
#include <nds/arm9/cp15_asm.h>

    .arch    armv5te
    .cpu     arm946e-s
#endif
#ifdef ARM7
    .cpu     arm7tdmi
#endif

    .balign 4
    .arm

BEGIN_ASM_FUNC swiSoftReset

    // Disable interrupts (REG_IME = 0, REG_IE = 0, REG_IF = 0xFFFFFFFF)
    mov     r0, #0x4000000
    mov     r1, #0
    str     r1, [r0, #0x208]
    mov     r1, [r0, #0x210]
    mvn     r1, r1
    mov     r1, [r0, #0x214]

#ifdef ARM7

    // Load execute address to lr before we clear all registers
    ldr     r0, =0x2FFFE34
    ldr     lr, [r0]

#endif

#ifdef ARM9

    // Disable TCM, caches and protection unit
    ldr     r0, =(CP15_CONTROL_ALTERNATE_VECTOR_SELECT | CP15_CONTROL_RESERVED_SBO_MASK)
    mcr     CP15_REG1_CONTROL_REGISTER(r0)

    // Disable cache
    mov     r0, #0
    mcr     CP15_REG7_FLUSH_ICACHE
    mcr     CP15_REG7_FLUSH_DCACHE

    // Wait for write buffer to empty
    mcr     CP15_REG7_DRAIN_WRITE_BUFFER

    // Load execute address to lr before we clear all registers
    ldr     r0, =0x2FFFE24
    ldr     lr, [r0]

#endif

    // Clear registers
    mov     r0, #0
    mov     r1, r0
    mov     r2, r0
    mov     r3, r0
    mov     r4, r0
    mov     r5, r0
    mov     r6, r0
    mov     r7, r0
    mov     r8, r0
    mov     r9, r0
    mov     r10, r0
    mov     r11, r0
    mov     r12, r0

    // Reset to the executable address
    bx      lr

    .pool
