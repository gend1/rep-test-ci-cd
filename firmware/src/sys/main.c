
/*
; ********************************************************************************
APB1_BUS_BASE             equ   0x80000000
APB2_BUS_BASE             equ   0x80010000

GPIO_BASE                 equ   (APB1_BUS_BASE+0x02000)     ; [55]
GPIO_PADR_OFFSET          equ   0x00                        ; Port A Data
GPIO_PADDR_OFFSET         equ   0x04                        ; Port A Direction
GPIO_PAIN_OFFSET          equ   0x10                        ; Port A Pins
PA_EN_PIN                 equ   (1<<2)                      ; Port A.2 EN
PA_RDY_PIN                equ   (1<<3)                      ; Port A.3 RDY
PA_ADDR0_PIN              equ   (1<<4)                      ; Port A.4 ADDR0
PA_ADDR1_PIN              equ   (1<<7)                      ; Port A.7 ADDR1

GPIO_PCDR_OFFSET          equ   0x80                        ; Port C Data
GPIO_PCDDR_OFFSET         equ   0x84                        ; Port C Direction
GPIO_PCIN_OFFSET          equ   0x88                        ; Port C Pins
GPIO_PCPU_OFFSET          equ   0xa8                        ; Port C Pull up
PC_LED_PIN                equ   (1<<7)                      ; Port C.7 GPOut LED VD3: "1" - Burns

; ********************************************************************************
AlarmState                                    ; Alarm led blinking
; --------------------------------------------------------------------------------
LED_BLINKING_TIME         equ   0x1f7777
; --------------------------------------------------------------------------------
; Take place: r0, r1, r2, r4
; --------------------------------------------------------------------------------
    ldr r4, =GPIO_BASE
    mov r1, #PC_LED_PIN
Blink1
    ldr r2, =LED_BLINKING_TIME
    Blink0
        subs r2, r2, #1
bne Blink0                                  ; jnz
eor r1, #PC_LED_PIN
str r1, [r4, #GPIO_PCDR_OFFSET]
b Blink1
*/

#include <stdint.h>

uint8_t* const APB1_BUS_BASE             = (uint8_t*)(0x80000000);
uint8_t* const APB2_BUS_BASE             = (uint8_t*)(0x80010000);

uint8_t*       RTC_BASE                  = APB1_BUS_BASE+0x07000 ;// [43]
uint8_t  const RTC_CR_OFFSET             = 0x10                  ;// [43]
uint8_t  const RTC_CR_XSEL_POS           =   0                   ;// [45]
uint8_t  const RTC_CR_WDT_EN_POS         =   2                   ;
uint8_t  const RTC_CR_FREEZ_POS          =   3                   ;
uint8_t  const RTC_CR_WDT_SEL_POS        =   4                   ;
uint8_t  const RTC_CR_SF_SEL_POS         =   8                   ;
uint8_t  const RTC_CR_OFF_DIV_POS        =   9                   ;



uint8_t* const GPIO_BASE                 = APB1_BUS_BASE+0x02000;// [55]

uint8_t* const GPIO_PADR_OFFSET          = GPIO_BASE+0x00       ;// Port A Data
uint8_t* const GPIO_PADDR_OFFSET         = GPIO_BASE+0x04       ;// Port A Direction
uint8_t* const GPIO_PAIN_OFFSET          = GPIO_BASE+0x10       ;// Port A Pins

uint8_t  const PA_EN_PIN                 = 1<<2                 ;// Port A.2 EN
uint8_t  const PA_RDY_PIN                = 1<<3                 ;// Port A.3 RDY
uint8_t  const PA_ADDR0_PIN              = 1<<4                 ;// Port A.4 ADDR0
uint8_t  const PA_ADDR1_PIN              = 1<<7                 ;// Port A.7 ADDR1

uint8_t* const GPIO_PCDR_OFFSET          = GPIO_BASE+0x80       ;// Port C Data
uint8_t* const GPIO_PCDDR_OFFSET         = GPIO_BASE+0x84       ;// Port C Direction
uint8_t* const GPIO_PCIN_OFFSET          = GPIO_BASE+0x88       ;// Port C Pins
uint8_t* const GPIO_PCPU_OFFSET          = GPIO_BASE+0xa8       ;// Port C Pull up



uint32_t const tLED_BLINKING_TIME        = 0x1f7777             ;
//uint32_t const tLED_BLINKING_TIME        = 0xff             ;

uint8_t  const PC_LED_PIN                = 1<<7                 ;

volatile int *PCDR   = (volatile int *) 0x80002080;
 volatile int *PCDDR  = (volatile int *) 0x80002084;
const int *fled_port_dr = (const int *)(&PCDR);
const int *fled_port_ddr = (const int *)(&PCDDR);
const int fled_port_pin = 5;

static volatile int *lport_dr = 0;
static volatile int *lport_ddr = 0;
static int lport_pin = 0;
int count = 0;
int delay = 0;

void init_pps_led(void)
{
    if (fled_port_dr != 0)
    {
        lport_dr = (volatile int *)(*fled_port_dr);
        lport_ddr = (volatile int *)(*fled_port_ddr);
        lport_pin = 1 << fled_port_pin;

        *lport_dr |= lport_pin;
        *lport_ddr |= lport_pin;
    }
}

int main(void)
{   
    init_pps_led();

     while (1)
    {
        count = 5;
         for(delay=0;delay<(20*tLED_BLINKING_TIME);delay++);

        if (lport_dr != 0)
        {
            while (count != 0)
            {
                *lport_dr |= lport_pin;
                for(delay=0;delay<10*tLED_BLINKING_TIME;delay++);

                *lport_dr &= ~lport_pin;
                for(delay=0;delay<(tLED_BLINKING_TIME);delay++);

                *lport_dr |= lport_pin;
                for(delay=0;delay<tLED_BLINKING_TIME;delay++);

                *lport_dr &= ~lport_pin;
                for(delay=0;delay<(tLED_BLINKING_TIME);delay++);

                --count;
            }
        }
    }
    //
/*
    while(1);
    //*(uint32_t*)RTC_BASE = 0x12345678;//(uint8_t)((3<<RTC_CR_XSEL_POS)|(0<<RTC_CR_WDT_EN_POS)|(2<<RTC_CR_WDT_SEL_POS)|(1<<RTC_CR_SF_SEL_POS));
    //
    uint8_t activ = PC_LED_PIN;
    //uint8_t activ = foo(PC_LED_PIN-1);
    while(1)
    {
        *GPIO_PCDR_OFFSET=activ;
        for(volatile uint32_t delay=0;delay<tLED_BLINKING_TIME;delay++);
        activ ^= PC_LED_PIN;
    };
    //
    while (1);
    //return;
*/
}
/*
uint8_t foo(uint8_t tmp)
{
    return tmp+1;
}
*/

/* #define lport_dr  (GPIO_PCDR_OFFSET)
#define lport_ddr (GPIO_PCDDR_OFFSET)
#define lport_pin (1 << 5); */

static uint16_t led_flash_delay = 1;

static uint64_t timer2_count_old  = 0;
static uint64_t get_speed_cnt_old = 0;

void pps_led_flash(void);

void init_pps_led_and_flash_while_1(void)
{
    init_pps_led();
    while(1)pps_led_flash();
}

void pps_led_flash(void)
{
    *lport_dr &= ~lport_pin;
    for(delay=0;delay<tLED_BLINKING_TIME;delay++);
    *lport_dr |=  lport_pin;
    for(delay=0;delay<tLED_BLINKING_TIME;delay++);
    return;
    /*
    if (new_1sec_for_led_flash)
    {
        new_1sec_for_led_flash = 0;
        //led_flash_delay = 400;
        led_flash_delay = 20000;
        //if (lport_dr != NULL)
        //*lport_dr |= lport_pin;
        *lport_dr &= ~lport_pin;
    }
    else if (led_flash_delay)
    {
        led_flash_delay --;
        //if ((lport_dr != NULL) && (led_flash_delay == 0))
        if(led_flash_delay == 0)
        {
            new_1sec_for_led_flash=1;
            //*lport_dr &= ~lport_pin;
            *lport_dr |= lport_pin;
        }
    }
    */
}
