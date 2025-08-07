.global _start             // устанавливаем стартовый адрес программы

VIC:
_start:
            B  _init       //
/*
_0:         B  _0          //
_1:         B  _1          //
_2:         B  _2          //
_3:         B  _3          //
_4:         B  _4          //
_5:         B  _5          //
_6:         B  _6          //
_7:         B  _7          //
*/
            mov  pc, #4    //  B    undef_I
            mov  pc, #4    //  B    soft_I
            mov  pc, #4    //  B    abort_P
            mov  pc, #4    //  B    abort_D
            mov  pc, #4    //  B
            mov  pc, #4    //  B    _irq_I    //  B    irq_I     ;
            mov  pc, #4    //  B    fast_UART_FIQ;
            mov  pc, #0x28 //  mov  pc, #0x28 //  7*4
            nop
/*
            nop
            nop
            nop
            nop
            nop
            nop
            nop
*/
/*
_irq_I:
.data       0xe24ee004 //   sub     lr, lr, #4
.data       0xf96d051f //   srsdb   sp!, #31
.data       0xe321f0df //   msr     CPSR_c, #223    @ 0xdf
.data       0xe320f000 //   nop     {0}
.data       0xe320f000 //   nop     {0}
.data       0xe92d5fff //   push    {r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, sl, fp, ip, lr}
.data       0xed2d0b20 //   vpush   {d0-d15}
.data       0xeef10a10 //   vmrs    r0, fpscr
.data       0xe92d0001 //   stmfd   sp!, {r0}
.data       0xe31d0004 //   tst     sp, #4
.data       0x03a00000 //   moveq   r0, #0
.data       0x13a00001 //   movne   r0, #1
.data       0x052d0004 //   pusheq  {r0}        @ (streq r0, [sp, #-4]!)
.data       0xe52d0004 //   push    {r0}        @ (str r0, [sp, #-4]!)
.data       0xeb0000cd //   bl  39c <int_proc>
.data       0xe49d0004 //   pop     {r0}        @ (ldr r0, [sp], #4)
.data       0xe3500000 //   cmp     r0, #0
.data       0x028dd004 //   addeq   sp, sp, #4
.data       0xe8bd0001 //   ldmfd   sp!, {r0}
.data       0xeee10a10 //   vmsr    fpscr, r0
.data       0xecbd0b20 //   vpop    {d0-d15}
.data       0xe8bd5fff //   pop     {r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, sl, fp, ip, lr}
.data       0xe320f000 //   nop     {0}
.data       0xf8bd0a1f //           @ <UNDEFINED> instruction: 0xf8bd0a1f
*/
_init:
//; RTC config:
//; select XTAL (32KHz)
//; switch off WDT
//_100:   B  _100
/*
        ldr r9, =0x80007010//(base_RTC_CR)
        ldr r1, [r9]
        ldr r2, =0x123
        cmp r1, r2
        strne r2, [r9,#0]

        ldr  r9, =0x8000402c//(base_DC_CFG)
        ldr r1, =0x0000
        str  r1, [r9,#0]

        ldr  r9, =0x80002004//(base_PADDR)
        ldr r1, =0x400
        str  r1, [r9,#0]

        ldr  r9, =0x80002000//(base_PADR)
        ldr r1, =0x400
        str  r1, [r9,#0]
*/
//; --------------------- set PLL----------------------------
/*

//setup_freq

        ldr r9, = 0x80004000//(base_PMU)

        ldr  R1, =0x33
        str  R1, [R9,#0x4]                   //; syf_next
        str  R1, [R9,#0x14] //; change freq                  nop

        ldr  R1, =0x00           //; ON PLL    21  -from pll , 41 from -lvds   00 -rc
        str  R1, [R9,#0x0]
        str  R1, [R9,#0x10]      //; change mode

        nop
        nop

//;               ldr  R1, =0x145F       //; enable PLL    50/8 * (95+1)=600 /4 ->150             /95=5f
//;               ldr  R1, =0x1250       //; enable PLL    50/8 * (79+1)=500 /2 ->250             /79=4f
//;               ldr  R1, =0x1260       //; enable PLL    50/8 * (89+1)=562,5 /2 ->281             /89=59
//;        mov  R1,  #0x0415       //; enable PLL    53/8 * (21/4)= -> 35 Mhz

        mov  R1,  #0x0440       //; enable PLL    50/8 * (64)= 406 /4 ->101.5             /79=4f
        orr r1, r1, #0x1000
        str  R1, [R9,#0x24]

        nop
        nop


//;        ldr  R8, =0x80002000
//;pll_lock
//;        ldr  R1, [R8,#0x10]
//;        AND  R1, R1, #0x0800
//;        beq  pll_lock

        mov  R1, #5//#10048
_pll_lock:
        subs  R1, R1, #1
        bne  _pll_lock

        ldr  R1, =0x01           //; ON PLL    21  -from pll , 41 from -lvds   00 -rc
        str  R1, [R9,#0x0]
        str  R1, [R9,#0x10]      //; change mode

        nop
        nop

//;******** bus clock setup ************

        ldr  R1, =0x33
        str  R1, [R9,#0x4]
        str  R1, [R9,#0x14] //; change freq                  nop

        nop
        nop

        mov  R0, #0x01
        str  R0, [R9,#0x30]  //; syc_ena

        mov  R0, #0x48
        str  R0, [R9,#0x38]   //; PDIV = (9+1), spi_clk = pdiv_clk = 101.5/10 = 10M

//;*************************

//alarm_state

        ldr  r9, =0x80002084//(base_PCDDR)
        ldr r1, =0x20
        str  r1, [r9,#0]
        ldr  r9, =0x80002080//(base_PCDR)

        mov r0, #0
        ldr r2, =(212*7)                                     //; 1 sec divider = (2^32 / 101 Mhz) * 5 cycles

_blink_alarm_led:

        add r0, r0, r2
        mov r1, r0, LSR #26                          //; #26 = LSR (31-5)
        str  r1, [r9,#0]

        b _blink_alarm_led
*/

/*
//; --------------------------------------------------------------------------------
  ldr r0,= 0x400000                           //; Enable unaligned address memory access !!??
  mcr p15, 0, r0, c1, c0, 0

//; --------------------------------------------------------------------------------
//; === Init RTC & Watch Dog Timer:
//; --------------------------------------------------------------------------------
  ldr r9, =0x80007000//RTC_BASE                           //; [43]
  ldr r1, =0x123//#mov r1, =0x123//#((3<<RTC_CR_XSEL_POS)|(0<<RTC_CR_WDT_EN_POS)|(2<<RTC_CR_WDT_SEL_POS)|(1<<RTC_CR_SF_SEL_POS))
  str r1, [r9, #0x10]//#RTC_CR_OFFSET]

//; --------------------------------------------------------------------------------
//; === Switch DC Off:
//; --------------------------------------------------------------------------------
  ldr r9, =0x80004000//PMU_BASE                           //; [11]
  mov r1, #0x0000                             //; [19]
  str r1, [r9, #0x2c]//#PMU_DC_CFG_OFFSET]

//; --------------------------------------------------------------------------------
//; === Init GPIOs:
//; --------------------------------------------------------------------------------
  ldr r9, =0x80002000//GPIO_BASE                          //; [55]
  mov r1, #0x80//#PC_LED_PIN
  str r1, [r9, #0x84]//#GPIO_PCDDR_OFFSET]            //; Pin PC.6 (LED) is GPOut
  mov r1, #0x00                               //; Led is OFF
  str r1, [r9, #0x80]//#GPIO_PCDR_OFFSET]
  str r1, [r9, #0xa8]//#GPIO_PCPU_OFFSET]             //; No Pull up

  mov r1, #0x04//#PA_RDY_PIN                         //; Pin PA.3 (RDY) is GPOut, others Pins PA are GPIn
  str r1, [r9, #0x04]//#GPIO_PADDR_OFFSET]
  mov r1, #0x00                               //; RDY = 0
  str r1, [r9, #0x00]//#GPIO_PADR_OFFSET]

//; --------------------------------------------------------------------------------
//; === Wait for EN to be 1:
//; --------------------------------------------------------------------------------
_Wait0:
  ldr r1, [r9, #0x10]//#GPIO_PAIN_OFFSET]
  tst r1, #0x02//#PA_EN_PIN                          //; and r1 & EN
  beq _Wait0                                   //; jz

  mov r1, #0x80//#PC_LED_PIN
  str r1, [r9, #0x80]//#GPIO_PCDR_OFFSET]             //; Led ON
*/


/*
            ldr r0, =0x400000            // Enable unaligned address memory access !!??
            mcr p15, 0, r0, c1, c0, 0
            //
            //; RTC config:
            //; select XTAL (32KHz)
            //; switch off WDT
            //
            ldr r9, =0x80007010          //
            ldr r1, [r9]
            ldr r2, =0x123
            cmp r1, r2
            strne r2, [r9,#0]
            //
*/
            ldr  sp,=0xfff00             // stack pointer
//            B   _GLOBAL__sub_I_main
            B   main
//_loop:      B    _loop     //

//.data
//hello: .ascii "Hello METANIT.COM!\n"    // данные для вывода

