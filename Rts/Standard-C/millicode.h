/* Copyright 1998 Lars T Hansen.
 *
 * $Id$
 *
 * Petit Larceny -- run-time-support prototypes.
 */

#ifndef MILLICODE_H
#define MILLICODE_H

#include "larceny-types.h"
#include "petit-config.h"


/* The following must be exported by compiled Scheme code. */

extern cont_t twobit_start_procedures[];
  /* A vector of procedure pointers, to be used by the procedure
     mc_petit_patch_boot_code (qv).
     */

extern cont_t twobit_start( CONT_PARAMS );
  /* Heap initialization procedure.
     */


/* The following millicode procedures are in millicode.c */

void scheme_init( word *globals );
  /* Initialize the things that need to be initialized once.
     */

void scheme_start( word *globals );
  /* Scheme_start runs a Scheme procedure in the context of the
     given globals vector.  The caller must allocate a stack frame and
     must also place arguments in the register save area in globals, 
     and must set up the argument count in globals[ G_RESULT ].  The
     procedure slot (REG0) must hold a Scheme procedure.

     Scheme_start will initialize the return address slot of the
     frame, and call the procedure.  If the procedure returns, then 
     scheme_start returns to its caller.

     Input:  As explained above.
     Output: Any values left in globals by the Scheme procedure.
     */

void twobit_integrity_check( word *globals, const char *name );
  /* Check the integrity of the virtual machine state, and assert
     if the state is not consistent.

     Input: None.
     Output: None.
     */

void mc_alloc_bv( word *globals );
  /* Allocate uninitialized non-pointer-containing memory.

     Input:  RESULT = number of bytes to allocate (fixnum).
     Output: RESULT = raw pointer to allocated memory.
     */

void mc_alloc( word *globals );
  /* Allocate uninitialized pointer-containing memory.

     Input:  RESULT = number of words to allocate (fixnum).
     Output: RESULT = raw pointer to allocated memory.
     */

void mc_alloci( word *globals );
  /* Allocate initialized pointer-containing memory.

     Input:  RESULT = number of words to allocate (fixnum).
             SECOND = object to initialize vector with (any object).
     Output: RESULT = raw pointer to allocated memory.
     */

void mem_stkuflow( void );
  /* Stack underflow handler.  
     This procedure is designed to be returned into -- not to be called.
     It restores a stack frame from the heap into the stack cache.

     The name (mem_ rather than mc_) is a historical artifact that will
     be corrected eventually. [FIXME]

     Input:  nothing.
     Output: nothing.
     */

void mc_stack_overflow( word *globals );
  /* Stack overflow handler.

     Input:  nothing.
     Output: nothing.
     */

void mc_capture_continuation( word *globals );
  /* Capture the current continuation.

     Input:  nothing.
     Output: RESULT = the captured continuation.
     */

void mc_restore_continuation( word *globals );
  /* Replace the current continuation with a saved continuation.

     Input:  RESULT = the saved continuation.
     Output: nothing.
     */

void mc_full_barrier( word *globals );
  /* Implements the full write barrier: for each assignment that
     has a pointer-valued rhs, it calls mc_partial_barrier.

     Input:  RESULT = left-hand-side (mutable object)
             SECOND = right-hand-side (any value)
     Output: nothing.
     */

void mc_partial_barrier( word *globals );
  /* The rhs is assumed to be a pointer.  If the rhs is in a younger
     generation than the rhs, then the lhs is added to the SSB of the
     older generation.

     Input:  RESULT = left-hand-side (mutable object)
             SECOND = right-hand-side (boxed object)
     Output: nothing.
     */

void mc_break( word *globals );
  /* If breakpoints are enabled, invokes the RTS debugger.

     Input:  nothing.
     Output: nothing (although the user can change registers in the debugger).
     */

void mc_timer_exception( word *globals, cont_t k );
  /* Exception handler for first-level timer expiration.  
     If timer interrupts are disabled, the timer is given a small amount
     of fuel, and execution continues.
     Otherwise, if the second-level timer is nonzero, then the first-level
     timer is given more fuel, and execution continues.
     Otherwise, a timer interrupt is signalled to the Scheme timer 
     interrupt handler. 

     'k' is a Scheme return address.

     A system event check is performed.

     Input:  nothing.
     Output: nothing.
     */

void mc_enable_interrupts( word *globals, cont_t k );
  /* Enable timer interrupts, set timer.
     'k' is a Scheme return address.

     A system event check is performed.

     Input:  RESULT = timer value (a positive fixnum)
     Output: nothing.
     */

void mc_disable_interrupts( word *globals, cont_t k );
  /* Disable timer interrupts and return the remaining time.
     'k' is a Scheme return address.

     A system event check is performed.

     Input:  nothing.
     Output: RESULT = timer value, or #f if interrupts were already disabled.
     */

void mc_exception( word *globals, word exception );
  /* Signal general non-continuable exception.  The exception is signalled 
     by calling the installed Scheme exception handler.

     'Exception' is a native exception code.

     Input:  nothing.
     Output: nothing.
     */

void mc_cont_exception( word *globals, word exception, cont_t k );
  /* Signal general continuable exception.  The exception is signalled 
     by calling the installed Scheme exception handler.

     'Exception' is a native exception code.
     'k' is the Scheme return address.

     Input:  nothing.
     Output: nothing.
     */

void mc_apply( word *globals );
  /* Given a procedure, a list of arguments, and the number of arguments,
     move the arguments to registers and sets things up as if for a
     procedure call.  The code for twobit_apply should call this
     procedure, then perform the jump as if for a procedure call.

     Input:  RESULT = procedure
             SECOND = list of arguments
	     THIRD  = argument count (length of list)
     Output: register values in globals[], set up for a call.
     */

void mc_restargs( word *globals );
  /* Cons up a rest argument list.  Does not perform any argument checking.

     Input:  RESULT = actual number of arguments.
             SECOND = number of fixed arguments.
     Output: Globals[ n+1 ] will point to a list of length RESULT-SECOND,
             holding the rest arguments.
     */

void mc_syscall( word *globals, cont_t k );
  /* Perform a call-out to a C procedure in the syscall table.

     A system event check is performed.

     Input:  RESULT = number of arguments.
             REG1 = index of procedure
	     REG2 ... = actual arguments
     Output: RESULT, as set up by the syscall.
     */

void mc_typetag( word *globals );
  /* Get the typetag of the argument, if it has one, otherwise signal
     an error.

     Input:  RESULT = the object.
     Output: RESULT = a fixnum (the type tag).
     */

void mc_typetag_set( word *globals );
  /* Change the typetag of the argument, if it has one.  If the
     argument does not have a typetag field, or the supplied tag is
     invalid, then signal an error.

     Valid tags are in the range [0..7].

     Input:  RESULT = the object.
             SECOND = the new typetag (a fixnum).
     Output: nothing.
     */

void mc_eqv( word *globals, cont_t k );
  /* Given two objects that are not eq?, test them for eqv?-ness.

     Input:  RESULT = an object.
             SECOND = another object.
     Output: a boolean.
     */

void mc_partial_list2vector( word *globals );
  /* Given a list and its length, create a vector that contains the 
     elements of the list.

     No error checking is performed; in particular, if the list is 
     circular then the procedure will loop uninterruptible forever 
     because no timer interrupt checks are performed.

     Input:  RESULT = a list.
             SECOND = a fixnum (the length of the list).
     Output: RESULT = a vector.
     */

void mc_bytevector_like_fill( word *globals );
  /* Given a bytevector-like structure and a fixnum in the range 0..255,
     fill the bytevector with the fixnum.

     No error checking is performed.

     Input:  RESULT = a bytevector-like structure.
             SECOND = a fixnum in the range 0..255.
     Output: Nothing.
     */

void mc_bytevector_like_compare( word *globals );
  /* Given two bytevector-like structures, compare them lexically in an
     alphabet of byte values, and return a negative number if the first 
     collates before the second, 0 if they are equal, and a positive number
     if the second collates before the first.

     No error checking is performed.

     Input:  RESULT = a bytevector-like structure.
             SECOND = another bytevector-like structure.
     Output: RESULT = a fixnum.
     */

void mc_petit_patch_boot_code( word *globals );
  /* This procedure is used only when loading a bootstrap heap.

     Given a list of thunks whose codevectors are #f, patch each 
     thunk with its appropriate procedure pointer.  The procedure 
     pointers are stored in a private array.  The length of the
     array must be equal to the length of the list, and the ordering
     of code pointers in the arrays must correspond to the ordering
     of thunks in the list.  The correspondence is normally ensured
     by the bootstrap heap dumper.

     Input:  RESULT = a list of thunks
     Output: RESULT = the same list
     */

void mc_scheme_callout( word *globals, int index, int argc, cont_t k,
		        bool preserve );
  /* Given:

     'index'    a millicode callback vector index (native int),
     'argc'     a number of arguments (native int),
     'k'        a scheme return address, and
     'preserve' a flag,

     save the current state and make a non-tail call to the specified
     procedure in the millicode callback vector with the specified
     number of arguments and return address.  If 'preserve' is nonzero,
     then RESULT is preserved across the call.

     Input:  RESULT, SECOND, THIRD, FOURTH: arguments to the callee
     Output: RESULT = current value (save_result == 1) 
                      or result (save_result == 0)
     */


/* The following system procedures are also in millicode.c */

void wb_lowlevel_enable_barrier( word *globals );
  /* Enable the write barrier.
     */

void wb_lowlevel_disable_barrier( word *globals );
  /* Disable the write barrier.
     */

void cache_setup( void );
  /* Perform any necessary magic to setup the processor cache.

     This is a no-op for Petit Larceny but the procedure is supplied for
     compatibility with the rest of the system.
     */

void mem_icache_flush( void *lo, void *limit );
  /* Flush the instruction cache between addresses lo (inclusive) and
     limit (exclusive).

     This is a no-op for Petit Larceny but the procedure is supplied for
     compatibility with the rest of the system.
     */

void execute_sigfpe_magic( void *context );
  /* Called with operating system dependent data when a SIGFPE is 
     received while executing millicode or compiled code.  This is
     a synchronous exception; the Scheme VM is guaranteed to be in a
     consistent state.

     The effect of calling this procedure is to signal an EX_FPE error,
     just like a call to mc_exception would do.  However,
     execute_sigfpe_magic() performs additional signal handling cleanup.
     */


/* The following system procedures are in arithmetic.c */

void initialize_generic_arithmetic( void );
  /* Initialize the generic arithmetic system.
     */

/* The following procedures implementing binary operations are in
   arithmetic.c. 

   Note: the operands can be _any_ objects, and unless noted 
   otherwise the procedures return the result, if the objects are of
   appropriate types, or call the exception handler with appropriate
   arguments.

   Input:  RESULT = first argument
           SECOND = second argument
   Output: RESULT = the result (number or boolean)
   */

void mc_add( word *globals, cont_t k );
void mc_sub( word *globals, cont_t k );
void mc_mul( word *globals, cont_t k );
void mc_div( word *globals, cont_t k );
void mc_quo( word *globals, cont_t k );
void mc_rem( word *globals, cont_t k );
void mc_neg( word *globals, cont_t k );
void mc_abs( word *globals, cont_t k );
void mc_equalp( word *globals, cont_t k );
void mc_lessp( word *globals, cont_t k );
void mc_less_or_equalp( word *globals, cont_t k );
void mc_greaterp( word *globals, cont_t k );
void mc_greater_or_equalp( word *globals, cont_t k );

/* The following unary operations are in arithmetic.c. 

   Note: the operand can be _any_ object, and unless noted 
   otherwise the procedures return the result, if the object is of
   appropriate type, or call the exception handler with appropriate
   arguments.

   Input:  RESULT = an object
   Output: RESULT = the numeric result
   */

void mc_exact2inexact( word *globals, cont_t k );
void mc_inexact2exact( word *globals, cont_t k );
void mc_real_part( word *globals );
void mc_imag_part( word *globals );
void mc_round( word *globals, cont_t k );
void mc_truncate( word *globals, cont_t k );

/* The following unary predicates are in arithmetic.c. 

   Note: the operand can be _any_ object, and unless noted 
   otherwise the procedures return the result, if the object is of
   appropriate type, or call the exception handler with appropriate
   arguments.

   Input:  RESULT = an object
   Output: RESULT = a boolean result
   */

void mc_zerop( word *globals );
void mc_complexp( word *globals );
void mc_rationalp( word *globals );
void mc_integerp( word *globals );
void mc_exactp( word *globals );
void mc_inexactp( word *globals );


/* Some millicode support routines (in multiply.c) */

void mul_32x32_to_64( word a, word b, word *hi, word *lo );
void umul_32x32_to_64( word a, word b, word *hi, word *lo );

#endif /* MILLICODE_H */

/* eof */
