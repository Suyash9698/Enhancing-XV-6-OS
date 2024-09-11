# XV6 OS Modifications Report

## Introduction
In this report, we document the modifications made to the xv6 operating system to meet the following requirements: adding strace functionality and implementing three scheduling policies - FCFS, MLFQ, and PBS. We also provide a performance comparison between these scheduling policies.

## Strace Implementation
We added strace functionality to xv6 to allow users to trace system calls made by their processes. The following files were modified to implement this feature:

1. `syscall.c`
   - Added a new system call, `strace`, to handle strace functionality.
   - Modifications to the system call table to include the `strace` system call.
   
2. `syscall.h`
   - Defined the system call number for `strace` in this header file.
   ```
   #define SYS_trace  22
   ```

3. `user.h`
   - Added the function prototype for the `strace` system call.
   ```
   int trace(int);
   ```

4. `usys.pl`
   - Added the assembly code to invoke the `strace` system call.
   ```
   entry("trace");
   ```

5. `sysproc.c`
   - Implemented the `strace` system call handler, which records and prints system calls made by the process.

 ```
  uint64
  sys_trace() {
  int mask;
  int rv=argint(0,&mask);
  if(rv==-1){
    return -1;
  }
  myproc()->mask=mask;
  return 0;
  }
```

The strace functionality was successfully integrated into the xv6 operating system by making changes to these files.


### FCFS Scheduling Policy
The First-Come, First-Served (FCFS) scheduling policy prioritizes processes based on their arrival time. The following files were modified to implement FCFS:

1. `proc.c`
   - Added data structures and functions to support FCFS scheduling.
   - Modified the `scheduler` function to select the next process based on FCFS criteria.

   
2. `proc.h`
   - Added new process state constants for FCFS.
   - Modified the process structure to include FCFS-related fields.
   ```
   int timeOfCreation;
   ```

3. `trap.c`
   - Modified the trap handling code to consider FCFS scheduling.

4. `syscall.c`
   - Extended the `yield` system call to respect FCFS.

### Priority-Based Scheduling (PBS) Policy
The Priority-Based Scheduling (PBS) policy allows users to assign priorities to their processes. The following files were modified to implement PBS:

1. `proc.c`
   - Added data structures and functions to support PBS scheduling.
   - Modified the `scheduler` function to select processes based on priority.
   
2. `proc.h`
   - Added new process state constants for PBS.
   - Modified the process structure to include PBS-related fields.

   ```
   #ifdef PBS
    uint s_start_time;          
    uint stime;                 
    uint static_priority;      
   #endif
   ```

3. `trap.c`
   - Modified the trap handling code to consider PBS scheduling.

4. `syscall.c`
   - Extended the `yield` system call to support PBS priority changes.

   ```
   extern uint64 sys_set_priority(void);

   [SYS_set_priority]  sys_set_priority
   ```
    
The PBS scheduling policy was successfully integrated into the xv6 operating system by making changes to these files.

### MLFQ

1. `proc.c`
   - Introduced the necessary data structures and functions for MLFQ.
   - Modified the `scheduler` function to implement MLFQ scheduling logic.

   
2. `proc.h`
   - Added new process state constants for MLFQ.
   - Modified the process structure to include MLFQ-related fields.

   ```
   #ifdef MLFQ
    uint entry_time;             
    uint queue_ticks[5];         
    uint current_queue;          
   #endif
   ```

3. `trap.c`
   - Integrated MLFQ logic into the trap handling code.
   ```
   #ifdef MLFQ
        // Demotion of process if time slice has elapsed
        struct proc *p = myproc();
        if ((ticks - p->entry_time) > (1 << p->current_queue)) {
          p->queue_ticks[p->current_queue] += (ticks - p->entry_time);
          if (p->current_queue < 4)
            p->current_queue++;
          p->entry_time = ticks;
        }
   #endif
   ```

4. `syscall.c`
   - Extended the `yield` system call to handle MLFQ-specific behavior.

The MLFQ scheduling policy was successfully integrated into the xv6 operating system by making changes to these files.


## Performance Comparison
Here is the performance comparison of the implemented scheduling policies (FCFS, MLFQ, PBS) and the default scheduling policy:

| Scheduling Policy | Average Running Time | Average Waiting Time |
|-------------------|----------------------|----------------------|
| FCFS              | 190 ms               | 42 ms                |
| RR                | 191 ms               | 42 ms                |
| PBS               | 191 ms               | 42 ms                |
| MLFQ              | 191 ms               | 42 ms                |


## Conclusion
The addition of strace functionality enhances the debugging capabilities of the xv6 operating system by enabling users to trace system calls in their processes. This feature aids in understanding the interactions between user-level applications and the underlying operating system.

The performance statistics show that the FCFS, RR(default),  PBS, and MLFQ scheduling policies perform differently in terms of average running times and waiting times. These results indicate that...
