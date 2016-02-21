#include "uthread.h"

void 
thread_schedule(void)
{
  thread_p t;
  int i;


  /*HW: 
      Read the schedular code below to understand what it is doing and the order 
        in which it schedules the threads.
   
    */

    /* To be improved and implemented in the HW: Change the schedular to implement the below behavior:
       The highest priority thread has to be scheduled first (priority=1 is higher than priority =2).
    	 If there are more than one thread with same priority, then they need to be scheduled in round-robin manner.

	 	 stop search when all threads are checked and none can be scheduled.
    */

  /* Find another runnable thread. */
    t=current_thread+1;
    int max_priority = -1;
  for (i=0;i<MAX_THREAD;i++) {
  	if (t >= all_thread+MAX_THREAD)
		t = all_thread;
    if (t->state == RUNNABLE) {
        if(t->priority < max_priority || max_priority == -1){
            next_thread = t;
            max_priority = t->priority;
        }
    }
	t = (t+1);
  }

  if (next_thread == 0) {
    printf(2, "thread_schedule: no runnable threads; deadlock\n");
    exit();
  }

  if (current_thread != next_thread) {         /* switch threads?  */
    printf(1,"Thread Switch %d -> %d\n",current_thread-all_thread,next_thread-all_thread);
    next_thread->state = RUNNING;
    thread_switch();
  } else
    next_thread = 0;
}
thread_p free_slot(){
    int i;
    for( i = 0; i < MAX_THREAD ; i++){
        if(all_thread[i].state == FREE){
            return (thread_p)&all_thread[i];
        }
    }
    return 0;
}
void 
thread_create(void (*func)(), int priority)
{
  thread_p t;
  t = free_slot();
  if(!t) {
    printf(2,"No free slot for new thread!\n");
    exit();
  }
  //HW: Your code here
  //starting from all_thread, scan and find out which slot is FREE
  //use that slot to create a new thread

  // set esp to the top of the stack
  // leave space for return address
  // push return address on stack
  // leave space for registers that thread_switch will push
  int funcptr = (int)func;
  int * stackptr = (int*)(t->stack + STACK_SIZE);
  stackptr--;
  *stackptr = funcptr;
  int *tmpstackptr = stackptr;
  //push the general purpose registers, which are used by popal
  //This instruction pushes all the general purpose registers onto the stack in the following order: 
  //EAX, ECX, EDX, EBX, ESP, EBP, ESI, EDI
  stackptr -= 5;
  //set the saved esp, which should be the esp before the pusha instruction
  *stackptr = (int)tmpstackptr;     // NOTE : apparently this doesn't make any difference, and the program still executes correctly
  //http://www.fermimn.gov.it/linux/quarta/x86/popa.htm ESP value pop'ed is not used
  stackptr -= 3;
  t->sp = (int)stackptr;
  t->priority = priority;
  t->state = RUNNABLE;
}

