	.text

/* Switch from current_thread to next_thread. Make next_thread
 * the current_thread, and set next_thread to 0.
 * Use eax as a temporary register, which should be caller saved.
 */
	.globl thread_switch
thread_switch:
	/* YOUR CODE HERE */
	call proxy
	ret
proxy:
	pushal

	movl current_thread,%eax
	movl %esp,(%eax)
	/*saved the state of the current thread, now can safely load the state of next_thread*/
	movl next_thread,%eax
	movl %eax,current_thread
	
	movl $0,next_thread
	movl (%eax),%esp
	popal
	ret				/* pop return address from stack */

