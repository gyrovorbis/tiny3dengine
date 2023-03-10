```                                    
        ;; Tiny 3d Engine for VMU
        ;;
        ;; >> War On Iraque Edition (06/01/08) <<
        ;;
        ;; by Rockin'-B, www.rockin-b.de

;                                                                            
; Copyright (c) 2003/2006/2023 Thomas Fuchs / The Rockin'-B, www.rockin-b.de       
;                                                                            
; Permission is granted to anyone to use this software for any purpose        
; and to redistribute it freely, subject to the following restrictions:       
;                                                                            
; 1.  The origin of this software must not be misrepresented. You must not    
;     claim that you wrote the original software. If you use this software    
;     in a product, an acknowledgment in the product documentation would be   
;     appreciated but is not required.                                        
;                                                                            
; 2.  ANY COMMERCIAL USE IS PROHIBITED. This includes that you must not use   
;     this software in the production of a commercial product. Only an explicit
;     permission by the author can allow you to do that.                      
;                                                                            
; 3.  Any modification applied to the software must be marked as such clearly.
;                                                                            
; 4.  This license may not be removed or altered from any distribution.       
;                                                                            
;                                                                            
;			     NO WARRANTY                                                 
;                                                                         
; THERE IS NO WARRANTY FOR THE PROGRAM.                                       
; THE PROGRAM IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND,               
; EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO,                 
; THE IMPLIED WARRANTIES OF FITNESS FOR A PARTICULAR PURPOSE.                 
; THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE PROGRAM IS WITH YOU.
; SHOULD THE PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY    
; SERVICING, REPAIR OR CORRECTION.                                            
;                                                                            
; IN NO EVENT WILL THE COPYRIGHT HOLDER BE LIABLE TO YOU FOR DAMAGES,         
; INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING 
; OUT OF THE USE OR INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED   
; TO LOSS OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY    
; YOU OR THIRD PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE WITH ANY OTHER  
; PROGRAMS), EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE       
; POSSIBILITY OF SUCH DAMAGES.                                                
;                                                                            


!!! matrix stack overflow not handled in push_matrix, should be handled before calling(if full, use other way: transform and retransform)

Later speedup possibilities:
*  - started
** - advanced
!  - fully finished
x  - not necessary anymore
?  - does it make sense?


**	- make fast transformation matrix multiplication by only doing the necessary ops
		-> original: 36 muls + 27 adds
!		-> translation: 3 adds
!		-> scaling:	12 muls
*		-> rotation:	16 muls + 8 adds
*	- inline called functions:
!		-> in "mul_16bit" inlined "twos_complement"
!		-> in "div_16bit" inlined "twos_complement"
!		-> in "dot_product" inlined "add_16bit"
!		-> in "dot_product_transposed" inlined "add_16bit"
**	- unroll some loops:
!		-> in "dot_product"
*		-> in "transform_point"
*		-> in "dot_product_transposed"

	- ensure that "clipping" and "draw_line" don't compute things twice
*	- when drawing polylines, use last lines last position to start new line
		-> saves calculation of screen position
!	- concerning the translation of matrices when multiplying them: try to remove this operation by:
!		1. accessing the (former transposed) matrix with 4 pointers, or
x		2. transpose the current matrix for every object and not every matrix multiplication. So the current matrix is always transposed
!	- when multiplying matrices: don't copy the result to temp location, handle 2 current matrices instead.
!	- because we are not using a projection matrix for projection, the first occuring matrix multiplication between a unit matrix and a transformation matrix.
		- save the first matrix multiplication by simply copying the transformation matrix to current matrix
**	- reorganize matrix creation
!		- translation matrix skeletons reside in RAM while rendering, only the transformation data is changed by direct adressing
!		- matrix stack is divided in stack and top of stack, 
!		-> stack is in workRAM bank 2 and top of stack is at the end of general purpose RAM
		- matrix skeltons don't reside in flashrom, but are created by clearing and placing some 1's at the right positions
	- combine display_framebuffer und clear framebuffer
	- inline "div_16bit" in project_point
**	- apply fast multiplication and divion psossible because VM allows one operand to be 16 bits and we are computing fixed points!
!		- mul_16bit
**		- div_16bit
?	- reorganize memory mapping onto workRAM and RAM?
**	- use VM's mul and div to make 16 bit mul and div
!	- make draw_line to not use draw_point
!	- move cam onto z-axis
!	  => save some 16 bit arithmetic in projection!!!
x?	- change the signed number support in mul and div, so that argument conversion is not neccessary
x	- in multiply_matrix: it's always the temp_matrix, that is multiplied to the current matrix,
x	=> therefore no rescue of R1 is needed, instead use constant "temp_matrix"
!	- possibly only need 3x4 matrices
!	- precompute offsets of sines/cosines in temporary matrix
*	- possibility to compute sine/cosine at the same time(for rotate_?)
!		-> put the two functions together
		-> clean up pointer(R1) rescue
		-> twos_complement is called twice(in sincos and in rotate_?), possibly reduce to 1 time
?		-> possibly precompute sine/cosine pairs for 0 - 360(359) degrees
*	- speed up transformation matrix usage 
!		-> merge application stage(demo) transformation value locations with those inside the matrix skeletons
		-> possibly make a whole function with five entry point via call(scale, translate,...) and one exit point via ret to combine what all got together
	- check if variable resque of subroutines
	  can be brought one level up to calling function level
	- check output variable writes in subroutines and
	  remanagement of those variables in calling functions
	  is redundant
	- check for unnecessary pointer resques in subroutines
	- necessary variable rescues are faster with (ld ?, add/sub, st ?) than with push/pop
!	- reduce handling of variable dimension to one bit in control

ToDo: 	move camera to align z-axis for better visuals, bring camera closer to projection plane for better 3D impression, scale projection plane so that it's height is about 2.0 units and equal to 2.0 meters, make draw_line and clip_and_draw_line work together more sophisticated, apply propper rounding(+ 0.5 and then cut) but where? , remove multiplication? problem, use points and point indices instead of only points => can save point transformations, use pointers to point to transformation values!!! bring camera onto z-axis!!! BUG in draw_line, check transformation matrices, projection prob: cutting last 8 bits of negative number ? projection...only displays one point!, visibility check for polylines, proceed put_polygon: polyline, debug all
!!! warning: after multiply_matrix is finished, the bottom row is not (0,0,0,1), but (tx,ty,tz,1)


08/01/2003:
    - added title and help screen
    - splited source code into files


29/04/2003:
	- trying to find out the BUG when concatenating several axis rotations
		- rx_fast + ry_mm = ok
		- rx_mm + ry_fast = failed!
		-> element 12 differs when using fast or mm rotate_y
		-> it's the negative value! <- no, not always..

28/04/2003:
	- BUG when translating and pressing opposite directions at the same time
		-> removed: in "get_inputs", R1 wasn't reinitialised
	- removed some variable resques in "transform_point"
	- removed some variable resques there
	- inlined "add_16bit" in "dot_product" and "dot_product_transposed"

27/04/2003:
	- implemented fast division! goes fine!

22/04/2003:
	- functions "rotate_?" still suffer from BUG when being combined
	- implemented fast "rotate_z"
	- BUG in "rotate_?" makes the rotation periodicaly switch direction
	- implemented fast "rotate_x", tested and debugged
	- implemented fast "translate" and "scale", both testet
	- removed carry clear in add/sub_16bit

18/04/2003:
	- beginning to implement fast transformation matrix multiplication 

17/04/2003:
	- PROBLEM: fast polyline drawing doesn't draw linesegments but the first
		-> swapping of points is the reason!
	- added (de)activation of clipping to edit mode "data" of the demo
	- started to implement fast polyline drawing:
		- save workRAM position to temporary location and reload when needed
	- implemented clipping disable bit in variable "control"
	- rewrote and finished clipping
		-> works now for all 4 sides of the screen
		!-> bottom probably not so good(1 pixel)
		=> little BUG removed: sub 31 instead of 32
	- speed up point exchange in "draw_line"
	- added handling of geometrical data format "polylines" in "put_polygon"
		-> converted cube into this format
		=> less access to flashrom than with lines
		=> possibility to speed up drawing compared to lines

15/04/2003:
	- inlined "twos_complement" in "mul_16bit" to avoid usage of R1
		-> speed-up
		-> cleaned up "mul_16bit"
	- removed "mul_16bit_slow"
	- cleaned up "twos_complement_16bit"
	- unrolled last short loop in "dot_product_transposed"
	- unrolled first short loop in "transform_point"
	- removed "tanspose_matrix"
	- replaced variable "dimension" with bit "full_dimension" in control
		-> unroled a loop in dot_product
		-> cleaned up "dot_product"
	- removed "sin", "cos" and "multiply_matrix_transposing"
	- merged "sin" and "cos" and made optimizations:
		-> for cosine, there is only very little computation necessary
	- cleaned up "translate" and "scale" to minimum, saved some push/pop 
	- merged transformation(translateion and scaling) values, 
	  removed copying in "translate" and "scale", 
	  made initialisation unnecessary by applying proper 1.0 scaling values to scale matrix skeleton


10/04/2003:
	- started to implement function "clipping"
		- left and right border checking for point 1
			-> still buggy, maybe because the rest of division is ignored
			? should use some type of bresenhams's algorithm?
	- changed the geometrical objects to cube and pyramid of points/lines
	- not a real BUG in demo, but not very userfriendly: changing activity of rendering modes rxy and rxz 
	  could leave a transformation in the background without notifiing to the user, changed that
	- added new geometrical object type "lines"
		-> applied changes in "put_polygon"
			- introduced new temporary variables header, npoints and nlines
				-> saves some setup overhead to reload that values
	- reduced variable "temp_vector" to 3 elements
		-> in "put_polygon" remove setting 4th element to 1.0
		-> shortened temp_vector in RAM to 6 bytes

09/04/2003:
	- applied changes to "dot_product_transposed" to leave out the last multiplication
	- MATRIX MULTIPLICATION BUG remains partially:
		- translation and scaling together does not allow negative scaling of y-axis
		-> some how the translation matrix skeleton is changed when sy gets negative
		- rotation around two axis fails
		=> solution: "twos_complement" nested in "multiply_matrix" nested in "dot_product"
		   accessed R1 while "dot_product" had changed the irbk bits!
		- made a workaround in "multiply_matrix"
	- current matrix handling BUG: in "put_polygon", current matrix pointer was overwritten
	- changed "display_matrix" to display 3x4 instead of 4x4 matrices
	- BUG in new "dot_product": irbk1 was only set when 4 dimension product was computed
		-> caused a distorted result matrix

08/04/2003:
	- regarding matrix multiplication BUG: 3rd line of source matrix is corrupted!
		-> element 34 remains correct, element 33 is lost(always zero)
	- remaining BUG in demo: rotation around y and z axis is distorted!
	- BUG in "reset_stack": forgot to adjust to 3x4 current matrices
	- made the current matrices to 3x4 matrices, involved changes in: "init_stack", matrix skeletons and value offsets
	- error in "pop_matrix": forgot to copy top-of-stack into currrent matrix, now done
	- made the matrix stack to only have 3x4 matrices, involved changes in "push_matrix" and "pop_matrix"
	- made the copying of the product matrix redundant! Involved changes in "multiply_matrix" and "dot_product"
	- totally enabled handling of 2 current matrices
	- in new "dot_product": the 4th multiplication is redundant! Removed!
	- removed some BUGs in new matrix multiplication.
		-> scaling and translation now works properly, but rotation(more than 1 axis) does not!
	- for debugging: changed "display_matrix" to allow the user to set xbnk => compare 2 matrices on both half of teh screen.
	

07/04/2003:
	- new BUG: when activating more than one transformation, it crashes
		- problem was in "dot_product" with adjusting the 16 pointers
		! now the BUG reduced to allow only adjustment of scaling and a lot other indicators
		- BUG report:
			- 1 transformation: translation ok, scaling ok, rotation only x-axis, not y or z
			- all further transformations are ignored
			-> all real matrix multiplications don't work
			-> result of MM is all zero!
	- started to remove matrix transposition
		- made memory 0 to F available
		- applied changes to "dot_product" and "multiply_matrix"
	- new BUG: when activating all rotations, the object is distorted
		-> found and removed: in "rotate_y" the wrong pointer was poped
	- implemented function "push_unit_matrix"
?no	- optimized "reset_stack": due to first matrix multiplication handling, the current matrix doesn't have to be set to a unit matrix
	- starting to implement 2 current matrices:
		- changed precomputed matrices in flashrom
		- changed offset values
		- R0 shall now always point current matrix:
			- applied changes to transformation functions	-> saves cycles
			- applied changes to "init_stack" and "reset_stack"


04/04/2003:
	-> rotation now works!
	- fixed another problem in sin/cos with angles bigger than 360 degrees
	- found an additional error in cos, that caused the rotation problem for angles bigger than 180 degrees
	- implemented function "copy_matrix" and applied changes to init_stack, reset_stack and all transformation matrix functions
	  to deal with new first matrix multiplication indicator in control
	  -> saves one matrix multiplication per frame 


03/04/2003:
	- found a little BUG in cos: acc was inspected instead of A_high
	- removed other little BUGs
	- implemented reset_stack as fast and simplified version of init_stack
	- found BUG in init_stack: data was copied into workRAM instead of GP RAM
	- applied changes to transformation functions
	- adjusted the matrix stack for new matrix locations in RAM and workRAM
	- modified init_stack, push_matrix and pop_matrix
	- found BUG in pop_matrix: variable stack_entries wasn't decreased
	- pre-computed adress of the transformation data inside of the skeletons in RAM
	- created matrix_skeletons in flashrom

12/03/2003:

	=> found major difference between slow and fast division:
	- ported the testing to test division
	=> found BUG in fast multiplication: multiplication of positive multiplier and negative multiplicand:
		-> result was positive instead of negative
		-> applied full sign controll like in slow multiplication
! now works !
	- implemented "test_mul_16bit_compare" to find the differences between slow and fast maultiplication
	  => the brute force method tests all possible operands, should take a while...
	  => added 100 kHz mode
	  => found BUG: operands weren't reloaded twice
	  => added error skip possibility to test for multiple errors
	  => added underline

11/03/2003:
	- still problem with point projection, especially when scaling or rotating
	- inserted waitrelease for button A and B in "get_input"
	- BUG occured:
		somehow, with every menu cycle when entering T_XZ, (t_z_high, t_z_low) is decreased
	  => found and removed! in "get_input" there were a bp acc... instead of bp c....
	- finished to speed up "draw_line" by not using "draw_point"
	- found and removed an old BUG in draw_point's shifting, #100 0000 instead of #1000 0000, forgot one zero!
	- reimplemented "div_16bit" to use VM's div functionality
	 => lot more speed, but rounding errors may occur due to discarding the low 8 bits of divisor
	- modified "project_point" because of fixed camera coordinates
		=> saved 2 adds, 2 subs and 2 push/pops and some others simple things
	!!! memory positions in SFR area cause errors on VM!!!
	  -> corrected
	!!! there exist problems with new multiplication
	- points are not properly transformed and projected
		-> appears only when the whole scene is translated behind projection surface
		-> appears also when rotating
	- modified "multiply_matrix" to multiply only 3x4 submatrix portion of 4x4 matrices
		=> saves 25 multiplications and 21 additions this way:
		-> instead of computing 16 dot products with 4 multiplications and 3 additions each,
			=> 64 multiplications 
			=> 48 additions
		   compute only 12 dot products with only 3 of them of 4 muls and 3 adds, the other 9 just 3 muls and 2 adds
			=> 39 multiplications
			=> 27 additions
	- changed "dot_product" to have variable dimension
	- modified "transform_point" to only compute 3 dot products, instead of 4
		=> save 4 multiplications and 3 additions
	- reimplemented function "mul_16bit" to use VM's multiplication abilities
	- introduced memory usage in free SFR RAM locations
		-> no push/pop needed for those
		-> save GP RAM space
	- starting to do some optimizations

08/03/2003:
	- little change to mode pictures:
	  * added a sixth line above for a better look, applied changes to draw_mode
	- found and removed polyline distortion BUGs:
	  * in "draw_line", a branch label got mixed,
	  * in method2 the y-axis has been decreased instead of increased
	- found BUG when displaying polylines:
		draw_point and draw_line changed the given points without push/pop
	some changes for demo:
	- changed edit mode none to data, added additional data
	  => the polygon data can now be changed while running demo!
	- deconfused axis rotation active monitoring
	- changed frequency D_pad mapping:
	  * down is 32 kHz SUB clock
	  * left/right is 50 kHz RC clock
	  * up is 100 kHz RC clock
	- increased rotation step size from 5 to 9

07/03/2003:
	- now rotation works a bit better,
!!! but not perfect !!!
	- found BUG in sin/cos that may cause rotation problems:
	  the angle transformation effected the original source angle
	  so that the increase/decrease fails..
	- rotation now works partially
	- found BUG: reason were several ret instructions in get_input so that the pop operations weren't performed
	- BIG BUGS: in emulator:
	 * when switching editing mode via pressing A, it locks in T XZ
	 on VM
	 * VM acts differently each time the game is startet, sometimes locks, sometimes slow and distorted screen
	 * from editing mode T XZ it goes to none, directly
	- added full range translation support to remove wrong direction translation problems
!!! but is error prone on softVMS, write to R1 causes problem !!!
	- changed get_inputs to allow all possible scaleing values like for rotation, too.
	  and increased the scaling unit from 5 to 32
	- added bit active to mode_render, applied changes to draw_mode and get_inputs,
	  => now the mode indicating bitmap is inverted if related transformation is active
	- implemented functions: "inc_16bit" and "dec_16bit"
	- angles now support range -360 to +360 in 16 bit 2's complement form,
	  => changes in sin and cos

06/03/2003:
	- found BUG in cos/sin:
	can only rotate +-90 degrees 
	- inserted code to move the object behind the projection surface
	- moved camera onto z-axis, applied changes to cube object, projection
	- BUGs in "demo":
	  * initial scale values were set to 0.0 instead 1.0
	  * forgot a debug infinit loop when scaling was active
	- implemented functions "demo", "draw_mode", "get_input"
	  resulting in a very powerful demo
	  * with possibility to adjust any transformation parameter
	  * enable/disable single transformations and
	  * changing the clock speed to 4 different speeds
	- as the scale and translation parameters are corresponding to all 3 dimensions,
	  I introduced a_x, a_y and a_z being 3 different rotation angles.
	=> adapted sin, cos, and rotate_?
	- BUG in draw_line,
!!! not removed !!!
	- inserted VRMAD2 refresh to polyline's draw_line in put_polygon
	- found fixed point BUG in functions "rotate_x" and "rotate_z"
	- found BUG in function "scale":
	  fixed point 1's were not properly inserted,
	  add 9 instead of add #9

05/03/2003:
	- rotation now works partially
	- found BUG in sinetable.i: .word swapped the bytes! Now sinetable.c produces .byte!
	- found BUG in functions "sin" and "cos":
	  the flashrom offset wasn't handled
	  fixed a little problem with negative angles in "cos"
	- found BUG in DirectVMS ala SoftVMS v1.8:
	  reads to VRMAD2 always get $FF, so push/pop doesn't work
	=> now displays more than one point on emu
!!! don't forget to remove for VMS version to not limit the number of points

	=> now the projection does well!
	- found BUG in "project_point", the underlying equation got a sign flipped!
	- found BUG in "mul_16bit", R1 was used, but not saved on stack!
	  -> caused problems in projection 

04/03/2003:
	- added a check in function "put_polygon" to ensure that enough points to draw are available
	- implemented a visibility check before drawing the points to screen
	- corrected function "mul_16bit" to be compatible with negative arguments 
	  and 8.8 bits fixed point, like "div_16bit"
	  => slow, maybe
	- inserted coordinate system
	- probably the multiplication got a similar problem with negative numbers...
	reorganized the fixed point compatibility of function "div_16bit",
	=> old: left shift quotient for 8 bits, the last 8 bits of the quotient were replaced by zero
	=> new: more precision by shifting left the dividend in the same manner as the quotient,
	   keeps the last 8 bits of precision!
	=> now "div_16bit" is pure 8.8 bits fixed point
03/03/2003:
	- found BUG in function "project_point":
		a temporary result wasn't loaded for Sx computation, but was loaded for Sy computation!
	=> vertical projection now seems to work, but horizontal doesn't
	- rewrote C code from the web to illustrate the nonrestoring division algorithm,
	=> realised, that I missunderstood the division of negative numbers
	=> solution: converting negative arguments and reconvert result

02/03/2003:
	- BUG in "div_16bit" is still not totaly removed!
		reason is possibly a difference to the underlying flowchart
	- related to this BUG: in "sub_16bit" and "add_16bit" the carry was cleared before exiting,
		although this carry was used by "mul_16bit"
	- removed BUG in 16 bit division:
		added functions "add_17bit" and "sub_17bit" that use the carry bit
		=> now the division uses the carry bit as sign indicator
	- located the BUG in 16 bit division:
		16 bit registers A_x should have a 17th sign bit and check this one instead of the 16th
01/03/2003:
	- found BUG in 16 bit division!
	!! not removed jet !!
	- found BUG in function "transform_point": the transformed point was written back to temp_vector in reverse order
	- found BUG in function "put_polygon": temp_vector was wrong initialized, 4th element was'nt fixed point 1.
	- found BUG in function "multiply matrix": the product was saved on stack, but written back to current matrix in reverse order!

28/02/2003:
	- cleaned up function "test_put_polygon" to increase translation values and perform translation from the start for every frame
	  instead of accumulating translations
	  => avoids rounding errors
	- found BUG in fix point multiplication  => 1x1 alias 0000000100000000 x 0000000100000000 gives 1 0000000000000000 instead of 0000000100000000 
	=> result needs to be shifted as much as there are quotient bits
	!!! BUG appears also in fixed point division, there a left shift of 8 bits should be done,
		the least significant byte of the quotient is taken as zero
	- fount BUG in "test_put_polygon", bne $?? wrong, should be bne #$??
	- found BUG in "display_matrix", now displays properly
	- found little BUG in "push_matrix": the 1's where placed one byte to much right
	- implemented function for debugging:
		"display_matrix"
		"display_vector"

27/02/2003:
	- extendet the "test_put_polygon" function to allow translation by pressing buttons
	- removed BUGS:
		in transform_point: matrix row selection fixed
		in translate: diagonal 1 selection fixed

28/12/2002:
	- proceeded in put_polygon
	- implemented "test_put_polygon"
	- created test polygon data

27/12/2002:
	- found BUG in div_16bit, now it's correct

17/12/2002:
	- little work on put_polygon
	- implemented function:
		"div_16bit"


16/12/2002:
	- started function:
		"put_polygon"
	- found & removed little BUG in clear_framebuffer
	  (first byte not cleared...)
	- draw_line seems to work now!
	- added functions:
		"sub_16bit"
	- little work on draw_line's methods
	- removed addition overflow BUG in function "draw_point"
	- started to implement functions:
		"rotate_y"
		"rotate_z"



09/12/2002:
	- finished "rotate_x"
	- started function "rotate_x"
	- implemented functions:
		"translate"
		"scale"
		"sin"
		"cos"
		"twos_complement_16bit"
	- removed little bug in push_matrix:
		init matrix creation for 3 instead of 4 columns
	- removed bug in RAM variable locating, decimal instead of hex
	- created sinetable with C-program
	- corrected some bugs in function "draw_line",
	  method0 and method2 are now partially working

02/12/2002:
	- implemented functions:
		"push_matrix"
		"pop_matrix"
		"init_stack"
		"transpose_matrix"
		"multiply_matrix"
	- notes on matrix multiplication:
	"temporary matrix"  x  "top-of-stack matrix"
	t11 t12 t13		s11 s12 s13
	t21 t22 t23	x	s21 s22 s23	= (t11*s11 + t12*s21 + t13*s31) (t21*s12 + t22*s22 + t23*s32) (t31*s13 + t32*s23 + t33*s33)
	t31 t32 t33		s31 s32 s33
	
	s11 s12 s13		t11 t21 t31
	s21 s22 s23	x	t12 t22 t32	= (s11*t11 + s12*t12 + s13*t13)... not the same!!
	s31 s32 s33		t13 t23 t33

25/11/2002:
	- started to work on matrix stack and matrix arithmetic:
		started implementing function:
			"transform_point"
			"dot_product"
	- corrected carry bit BUG in function "mul_16bit"
	- implemented testing functions:
		"test_add_16bit"
		"test_mul_16bit"
	- started implementation of 16 bit 2's complement multipication
	  in function "mul_16bit"
	- implemented 16 bit 2's complement addition
	  in function "add_16bit"

17/11/2002:
	!!! BUG in draw_point !!!
	!!! draw_line unfinished !!!
	- started to implement function:
		- draw_line(Bresenham's algorithm)
	- implemented first "rendering" function:
		- draw_point
	- implemented basic function set:
		- clear_framebuffer
		- display_framebuffer
		- write_selected_half_of_screen
```
