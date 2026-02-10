//Bootloader introduction:
//  The first program that CPU will execute after reset state
//  Used to load main programs or OS to faster memories.

//The booting program is stored in ROM
//Booting program will move instr & data from DRAM to IM and DM

void boot() {
    extern unsigned int _dram_i_start;       //instruction start address in DRAM.
    extern unsigned int _dram_i_end;         //instruction end address in DRAM.
    extern unsigned int _imem_start;         //instruction start address in IM

    extern unsigned int __sdata_start;       //main data start address in DM.
    extern unsigned int __sdata_end;         //main data end address in DM.
    extern unsigned int __sdata_paddr_start; //main data start address in DRAM

    extern unsigned int __data_start;        //main data start address in DM.
    extern unsigned int __data_end;          //main data end address in DM.
    extern unsigned int __data_paddr_start;  //main data start address in DRAM

    // New GS-DMA programming model
    // Descriptor list is placed at the end of DM: 0x0002_FF00 ~ 0x0002_FFFF
    typedef struct {
        unsigned int DMASRC;     // source address
        unsigned int DMADST;     // destination address
        unsigned int DMALEN;     // total length (bytes)
        unsigned int NEXT_DESC;  // pointer to next descriptor
        unsigned int EOC;        // 1 -> end of chain
    } dma_desc_t;

    volatile dma_desc_t *const desc0 = (dma_desc_t *)0x0002FF00;
    volatile dma_desc_t *const desc1 = (dma_desc_t *)0x0002FF14; // +20 bytes
    volatile dma_desc_t *const desc2 = (dma_desc_t *)0x0002FF28; // +40 bytes

    // Fill three descriptors: IM instructions, .sdata, .data
    desc0->DMASRC    = (unsigned int)&_dram_i_start;
    desc0->DMADST    = (unsigned int)&_imem_start;
    desc0->DMALEN    = (unsigned int)&_dram_i_end - (unsigned int)&_dram_i_start + 1;
    desc0->NEXT_DESC = (unsigned int)desc1;
    desc0->EOC       = 0u;

    desc1->DMASRC    = (unsigned int)&__sdata_paddr_start;
    desc1->DMADST    = (unsigned int)&__sdata_start;
    desc1->DMALEN    = (unsigned int)&__sdata_end - (unsigned int)&__sdata_start + 1;
    desc1->NEXT_DESC = (unsigned int)desc2;
    desc1->EOC       = 0u;

    desc2->DMASRC    = (unsigned int)&__data_paddr_start;
    desc2->DMADST    = (unsigned int)&__data_start;
    desc2->DMALEN    = (unsigned int)&__data_end - (unsigned int)&__data_start + 1;
    desc2->NEXT_DESC = 0u; // not used when EOC is 1
    desc2->EOC       = 1u; // last descriptor

    // Program DMA registers
    volatile unsigned int *const DMAEN_REG     = (unsigned int *)0x10020100; // DMAEN
    volatile unsigned int *const DESC_BASE_REG = (unsigned int *)0x10020200; // DESC_BASE

    // Enable external interrupt for DMA completion
    asm("li t0, 0x800");
    asm("csrw mie, t0"); // enable MEIE

    // Provide base of descriptor list then enable DMA
    *DESC_BASE_REG = (unsigned int)desc0;
    *DMAEN_REG     = 1u;

    // Sleep until DMA raises interrupt
    asm("wfi");

    // Disable machine external interrupt (handled by ISR)
    asm("li t0, 0x000");
    asm("csrw mie, t0");
}