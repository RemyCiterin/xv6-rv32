#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "defs.h"

volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
  if(cpuid() == 0){
    printf(" _____   ____         ____  __  __     ____   _____\n");
    printf("|  __ \\ / __ \\       / __ \\|  \\/  |   / __ \\ / ____|\n");
    printf("| |  | | |  | | ___ | |  | | \\  / |  | |  | | (___\n");
    printf("| |  | | |  | |/ _ \\| |  | | |\\/| |  | |  | |\\___ \\\n");
    printf("| |__| | |__| | (_) | |__| | |  | |  | |__| |____) |\n");
    printf("|_____/ \\____/ \\___/ \\____/|_|  |_|   \\____/|_____/\n");

    printf("\nA port of MIT's xv6 OS to my rv32ima softcore. It is a fork of \n");
    printf("git@github.com:michaelengel/xv6-rv32.git with some minor midifications.\n");

    consoleinit();
    printfinit();
    printf("xv6 kernel is booting:\n");
    printf("- physical page allocator\n");
    kinit();         // physical page allocator
    printf("- create kernel page table\n");
    kvminit();       // create kernel page table
    printf("- turn on paging\n");
    kvminithart();   // turn on paging
    printf("- process table\n");
    procinit();      // process table
    printf("- trap vectors\n");
    trapinit();      // trap vectors
    printf("- install kernel trap vector\n");
    trapinithart();  // install kernel trap vector
    printf("- set up interrupt controller\n");
    plicinit();      // set up interrupt controller
    printf("- ask PLIC for device interrupts\n");
    plicinithart();  // ask PLIC for device interrupts
    printf("- buffer cache\n");
    binit();         // buffer cache
    printf("- inode cache\n");
    iinit();         // inode cache
    printf("- fill table\n");
    fileinit();      // file table
    printf("- first user process\n");
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
      ;
    __sync_synchronize();
    printf("hart %d starting\n", cpuid());
    kvminithart();    // turn on paging
    trapinithart();   // install kernel trap vector
    plicinithart();   // ask PLIC for device interrupts
  }

  printf("\nstart scheduler!\n");
  scheduler();
}
