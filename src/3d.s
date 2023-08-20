                                    
        ;; Tiny 3d Engine for VMU
        ;;
        ;; >> War On Iraque Edition (06/01/08) <<
        ;;
        ;; by Rockin'-B, www.rockin-b.de

;                                                                            
; Copyright (c) 2003/2006 Thomas Fuchs / The Rockin'-B, www.rockin-b.de       
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



        ;; coordinate system:
        ;;
        ;;
        ;; 0________ + x-axis
        ;; |\
        ;; | \
        ;; |  \
        ;; |   \ + z-axis
        ;; |    \
        ;; |     \
        ;; |      \ 
        ;;
        ;; + y-axis


        ;; RAM coordination:

count = $10              ; general loop counting variable

        ;; variables for function "draw_line" and "draw_point"
point1_x = $11           ; 0 - 47 screen coordinate: column
point1_y = $12           ; 0 - 31 screen coordinate: row
point2_x = $13
point2_y = $14

        ;; some synonyms for function "draw_line"
x       equ     $11            ; x  = point1_x
y       equ     $12            ; y  = point1_y
dx      equ     $13            ; dx = point2_x
dy      equ     $14            ; dy = point2_y
t       equ     $15            ; t  != b

        ;; 16 bit arithmetic registers
        ;; NOTE: one 16 bit number is in 2's complement and 8 bits before and 8 bits after the fixed point
        ;; => modifies 16 bit multiplication
A_high  = $16
A_low   = $17
B_high  = $18
B_low   = $19
C_high  = $1a
C_low   = $1b

        ;; matrix stack control
stack_entries   = $10
max_entries     equ 5


;; pointer adresses to transformation matrices:

t_start         equ     88
s_start         equ     112
rx_start        equ     136
ry_start        equ     160
rz_start        equ     184
c1_start        equ     208
c0_start        equ     232


tx_high         equ     106
tx_low          equ     107
ty_high         equ     108
ty_low          equ     109
tz_high         equ     110
tz_low          equ     111
;tx_high         equ     94
;tx_low          equ     95
;ty_high         equ     102
;ty_low          equ     103
;tz_high         equ     110
;tz_low          equ     111

sx_high         equ     112
sx_low          equ     113
sy_high         equ     122
sy_low          equ     123
sz_high         equ     132
sz_low          equ     133

rx_c1_high      equ     146
rx_c1_low       equ     147
rx_ns_high      equ     148
rx_ns_low       equ     149
rx_s_high       equ     154
rx_s_low        equ     155
rx_c2_high      equ     156
rx_c2_low       equ     157

ry_c1_high      equ     160
ry_c1_low       equ     161
ry_s_high       equ     164
ry_s_low        equ     165
ry_ns_high      equ     176
ry_ns_low       equ     177
ry_c2_high      equ     180
ry_c2_low       equ     181

rz_c1_high      equ     184
rz_c1_low       equ     185
rz_ns_high      equ     186
rz_ns_low       equ     187
rz_s_high       equ     192
rz_s_low        equ     193
rz_c2_high      equ     194
rz_c2_low       equ     195


        ;; matrix transformation variables
        ;; SOME MAY OVERLAP!

        ;; for translation
        ;; !!! order must not be changed !!!
;t_x_high        equ     $1c
;t_x_low         equ     $1d
;t_y_high        equ     $1e
;t_y_low         equ     $1f
;t_z_high        equ     $20
;t_z_low         equ     $21

        ;; for scaling
        ;; !!! order must not be changed !!!
;s_x_high        equ     $22
;s_x_low         equ     $23
;s_y_high        equ     $24
;s_y_low         equ     $25
;s_z_high        equ     $26
;s_z_low         equ     $27

        ;; for rotation
        ;; 2's complement angle(MSB), values from -360 to +360 degrees
ax_high        equ     $28
ax_low         equ     $29
ay_high        equ     $2a
ay_low         equ     $2b
az_high        equ     $2c
az_low         equ     $2d
        ;; !!! order must not be changed !!!
sin_high        equ     $2e
sin_low         equ     $2f
cos_high        equ     $30
cos_low         equ     $31

        ;; for transformation
        ;; 1x4 vector: (x, y, z), 2 bytes each
temp_vector     equ     $32
;; reserved till including $37

        ;; variable that holds the offset in workRAM bank 2 where a new top element would start
        ;; stack grows fram adress 0 upwards, 24 bytes a 3x4 matrix
stack_top       equ     $38
        ;; flashrom access offset
offset          equ     $3a     

control         equ     $3b
;; bits in control
sign            equ     0
sign_sin        equ     0
sign_cos        equ     1
first_mm        equ     2       ; indicates the first matrix multiplication
current_matrix  equ     3
full_dimension  equ     4       ; if set, 4th dimension is enabled
no_clipping     equ     5       ; if set to 1, clipping is disabled for higher speed
fast_polyline   equ     6       ; if set to 1, "draw_line" does not have to recompute first screen position

;; demo user input mode control:
mode_render     equ     $3c
mode_edit       equ     $3d
;; bits in mode_render:
do_t            equ     7
do_s            equ     6
do_rx           equ     5
do_ry           equ     4
do_rz           equ     3
active          equ     2       ; for draw_mode: indicates if transform related to current edit mode is active
;; bits in mode_edit:
edit_txy        equ     7
edit_txz        equ     6
edit_sxy        equ     5
edit_sxz        equ     4
edit_rxy        equ     3
edit_rxz        equ     2
edit_freq       equ     1
edit_data       equ     0

        ;; transformation matrix stuff
        ;; convention:
        ;; current matrix is accessed by R0,
        ;; temporary matrix is accessed by R1
        ;; one matrix is a 4x4 matrix of 16 bit numbers --> 32 bytes per matrix
        ;; alignment of one matrix in RAM: rowwise(transposed vector), top to bottom
        ;;      when multiplying two matrices, current matrix is transposed
        ;; alignment of one vector in RAM: left to right



        ;; camera position constants
        ;;      for reasons of efficiency, the camera is aligned with z-axis
;Cx_high         equ     0
;Cx_low          equ     0
;Cy_high         equ     0
;Cy_low          equ     0
Cz_high         equ     %10000001       ;; -127
Cz_low          equ     0

        ;; bits in keys
pressed_sleep   equ     7       ; same like port 3, if 0: button pressed
pressed_mode    equ     6
pressed_b       equ     5
pressed_a       equ     4
pressed_right   equ     3
pressed_left    equ     2
pressed_down    equ     1
pressed_up      equ     0


;; variables that are used temporary or as argument for function call,
;; they don't have to be saved on stack
;; and use SFR area in RAM, so don't waste GP RAM space

;free:       equ     $3e ; $10F            ; for dot_product dimension
T_high          equ     $3f ; $116            ; for multiplication temp variable
T_low           equ     $40 ; $117
T_vrmad1        equ     $44
T_vrmad2        equ     $45
T_b             equ     $46

        ;; temporary storage of geometrical data properties
header          equ     $39     
npoints         equ     $41
nlines          equ     $42
npolylines      equ     $43


;; 32 bytes temporary values for fast rotation
temp_storage    equ     $47


        ;; parts borrowed from tiny tetris by Marcus Comstedt

	.include "sfr.i"

	;; Reset and interrupt vectors
	
	.org	0

	jmpf	start

	.org	$3

	jmp	nop_irq

	.org	$b

	jmp	nop_irq
	
        .org	$13

        jmp     nop_irq

	.org	$1b

	jmp	t1int
	
	.org	$23

	jmp	nop_irq

	.org	$2b

	jmp	nop_irq
	
	.org	$33

	jmp	nop_irq

	.org	$3b

	jmp	nop_irq

	.org	$43

	jmp	nop_irq

	.org	$4b

	clr1	p3int,0
	clr1	p3int,1
nop_irq:
	reti



        ;; some firmware calls that can be found
        ;; in various homebrew games in this form

        .org $100
writeflash:
        not1 ext, 0
        jmpf writeflash
        ret

        .org $110
verifyflash:
        not1 ext, 0
        jmpf verifyflash
        ret

        .org $120
readflash:
        not1 ext, 0
        jmpf readflash
        ret




	.org	$130
	
t1int:
	push	ie
	clr1	ie,7
	not1	ext,0
	jmpf	t1int
	pop	ie
	reti

		
	.org	$1f0

goodbye:	
	not1	ext,0
	jmpf	goodbye


	;; Header
	
	.org	$200

        .text 16   "Tiny3dEngine"
        .text 32   "by Rockin'-B, www.rockin-b.de"
        .string 16 "waterbear"

	;; Icon header
	
  .include icon "../img/vms_icon.gif" speed=16
	
        ;; Your main program starts here.

start:
        clr1 ie,7               ; block nonmasked interrupts
        mov #$a1,ocr            ; clock divisor 6, subclock mode(32kHz), main clock stopped
        mov #$09,mcr            ; refresh rate 166Hz, Graphic mode on
        mov #$80,vccr           ; lcd enabled
        clr1 p3int,0
        clr1 p1,7
        mov #$ff,p3             ; initialise keys

        set1 ie,7               ; enable all interrupts

        call clrscr             ; clear screen

; display title
        mov #<title, trl
        mov #>title, trh
        call setscr

.waitkey1:
        call getkeys
        be #$FF, .waitkey1

.waitrelease1:
        call getkeys
        bne #$FF, .waitrelease1

; display help
        mov #<help, trl
        mov #>help, trh
        call setscr

.waitkey2:
        call getkeys
        be #$FF, .waitkey2

.waitrelease2:
        call getkeys
        be #$FF, .waitrelease2

        callf demo 
;        callf test_transform_matrices
;        callf test_trigonometrics

.loop:
        callf getkeys
        br .loop


        ;; some needful functions

        .include "misc.i"

        .include "3d_demo.i"

        .include "3d_test.i"




        ;; function: "display_vector"
        ;;      for debugging: displays the first 3 elements of the specified vector at the top of the screen
        ;; INPUTS: R1 points to first element of vector to display


display_vector:
        push 1
        push 2
        push xbnk
        push count

        mov #$80, 2
        mov #0, xbnk
        mov #6, count

.loop:
        ld @R1
        st @R2
        inc 1
        inc 2
        dbnz count, .loop


        ;; underline to ease bit enumeration/position counting
        mov #6, count

.loop1:
        mov #$FF, @R2
        inc 2
        dbnz count, .loop1

        pop count
        pop xbnk
        pop 2
        pop 1

        ret






        ;; function     "draw_point"
        ;;              - draws the specified point into the framebuffer(workRAM)
        ;;                without to overdraw other things
        ;; INPUTS:      - point1_x, 
        ;;              - point1_y point coordinates


draw_point:
        push acc
        push vrmad1
        push vrmad2
        push vsel

        callf adress_workRAM

        clr1 vsel, ince        ; make sure that workRAM pointers don't increase automatically

        or vtrbf               ; don't delete previously drawn pixels
        st vtrbf

        pop vsel
        pop vrmad2
        pop vrmad1
        pop acc

        ret



        ;; function     "adress_workRAM"
        ;;              - converts screen coordinates to work RAM byte-adress
        ;;                and a byte holding a 1 where the exact adress is
        ;; INPUTS:      - point1_x
        ;;              - point1_y
        ;; OUTPUTS:     - vrmad1  - work RAM byte adress
        ;;              - vrmad2
        ;;              - acc     - bit adress....

adress_workRAM:
        push c
        push b

        ;; map screen coordinates to bit-of-screen

        mov #48, b
        ld point1_y
        st c
        xor acc

        mul                     ; point1_y * 48

        push acc
        ld c
        add point1_x                    ; !!! overflow can happen
        st c
        pop acc                 ; (point1_y * 48) + point1_x

        bn psw, cy, .no_overflow        ; !!! now check for overflow
        clr1 psw, cy
        inc acc

.no_overflow:

        ;; map this position to byte-of-screen and bit-in-byte

        mov #8, b

        div                     ; ((point1_y * 48) + point1_x) / 8
                                ; c holds # of screen byte where the point is in
                                ; b holds # of bit in screen byte(little endian)

        ld c
        st vrmad1
        mov #0, vrmad2

        ;; addressing in workRAM finished, shift point to right position in byte

        mov #%10000000, acc
        inc b

.shift_loop:
        dbnz b, .shift_right
        br .end

.shift_right:
        ror
        br .shift_loop

.end:
        pop b
        pop c

        ret


        .include "3d_draw_line.i"

        .include "3d_framebuffer.i"


        ;; 16 bit arithmetic functions:

        ;; function:    "twos_complement_16bit"
        ;; INPUTS:      - R1, points to LOW 8 bit portion
        ;;                of 16 bit value to convert
        ;; OUTPUTS:     - 16 bit value, R1 points to high 8 bit portion


twos_complement_16bit:
        push acc

        ld @R1
        xor #%11111111
        add #1
        st @R1
        dec 1
        ld @R1
        xor #%11111111
        addc #0

        st @R1

        ;; overflow CAN NOT occur
        pop acc

        ret




        ;; function:    "inc_16bit"
        ;; INPUTS:      - R1, points to LOW 8 bit portion
        ;;                of 16 bit value to convert
        ;; OUTPUTS:     - 16 bit value, R1 points to high 8 bit portion


inc_16bit:
        push acc

        ld @R1
        add #1
        st @R1

        dec 1
        bn psw, cy, .end
        inc @R1

.end:
        pop acc

        ret




        ;; function:    "dec_16bit"
        ;; INPUTS:      - R1, points to LOW 8 bit portion
        ;;                of 16 bit value to convert
        ;; OUTPUTS:     - 16 bit value, R1 points to high 8 bit portion


dec_16bit:
        push acc

        ld @R1
        sub #1
        st @R1

        dec 1
        bn psw, cy, .end
        dec @R1

.end:
        pop acc

        ret


        .include "3d_add.i"

        .include "3d_sub.i"

        .include "3d_mul.i"

        .include "3d_div.i"

        .include "3d_dot_product.i"


        ;; function:    "transform_point"
        ;;              - multiplies a 3D point with the current matrix
        ;; INPUTS:      - 0 points to current matrix
        ;;              - 1 points to 4D vector(point_x, point_y, point_z, 1)
        ;; NEEDS:       - additional(to variable rescue on enter) 8 bytes in stack

transform_point:
;        push acc
        push 0                   ; save current matrix position, need 0 for row selection
;        push 1                  
        push count

        ; need to perform 3 dot products for 3 dimensions

        callf dot_product_transposed

        push A_high             ; save for later
        push A_low              
                                
        inc 0                   ; select next row in current matrix

        callf dot_product_transposed

        push A_high             ; save for later
        push A_low              
                                
        inc 0                   ; select next row in current matrix

        callf dot_product_transposed

        push A_high             ; save for later
        push A_low              
                                
        mov #6, count           ; now overwrite the given point with the new point

        ;; start at third element's low 8 bit
        ld 1
        add #5
        st 1

.write:
        pop acc
        st @R1
        dec 1
        dbnz count, .write

        pop count
;        pop 1
        pop 0
;        pop acc

        ret



        .include "3d_stack.i"

        .include "3d_matrix.i"

        ;; matrix transformation functions
        ;; -> multiply the current matrix
        ;;    with the appropriate transformation matrix from the left.

        .include "3d_translate.i"

        .include "3d_scale.i"

        .include "3d_rotate_x.i"

        .include "3d_rotate_y.i"

        .include "3d_rotate_z.i"


        ;; high level display routines

        .include "3d_put_polygon.i"

        .include "3d_project_point.i"

        .include "3d_clip_and_draw_lines.i"

        .include "3d_sincos.i"

        .include "3d_polygon_data.i"


;; transformation matrix skeletons
;;      - matrix 1 to 5 are only 3x4 matrixes
;;      - last matrix is regular 4x4

;; MEMORY CONSUMPTION:  5 matrices * 12 elements * 2 bytes each + 1 matrix * 16 elements * 2 bytes each
;;                      = 152 bytes


;; LOCATION IN RAM
;;      - this data is copied into RAM
;;      - adress range 104 to 255 same order like here

;; adresses in RAM:

;t_start         equ     88
;s_start         equ     112
;rx_start        equ     136
;ry_start        equ     160
;rz_start        equ     184
;c1_start        equ     208
;c0_start        equ     232
;
;
;tx_high         equ     94
;tx_low          equ     95
;ty_high         equ     102
;ty_low          equ     103
;tz_high         equ     110
;tz_low          equ     111
;
;sx_high         equ     112
;sx_low          equ     113
;sy_high         equ     122
;sy_low          equ     123
;sz_high         equ     132
;sz_low          equ     133
;
;rx_c1_high      equ     146
;rx_c1_low       equ     147
;rx_ns_high      equ     148
;rx_ns_low       equ     149
;rx_s_high       equ     154
;rx_s_low        equ     155
;rx_c2_high      equ     156
;rx_c2_low       equ     157
;
;ry_c1_high      equ     160
;ry_c1_low       equ     161
;ry_s_high       equ     164
;ry_s_low        equ     165
;ry_ns_high      equ     176
;ry_ns_low       equ     177
;ry_c2_high      equ     180
;ry_c2_low       equ     181
;
;rz_c1_high      equ     184
;rz_c1_low       equ     185
;rz_ns_high      equ     186
;rz_ns_low       equ     187
;rz_s_high       equ     192
;rz_s_low        equ     193
;rz_c2_high      equ     194
;rz_c2_low       equ     195


        .include "3d_matrix_skeletons.i"


        ;; some edit mode indicator bitmaps

mode_pix:
        .byte %00000000,%00000000
        .byte %01110000,%01010101
        .byte %00100000,%01010101
        .byte %00100000,%00100101
        .byte %00100000,%01010010
        .byte %00100000,%01010010

        .byte %00000000,%00000000
        .byte %01110000,%01010111
        .byte %00100000,%01010001
        .byte %00100000,%00100010
        .byte %00100000,%01010100
        .byte %00100000,%01010111

        .byte %00000000,%00000000
        .byte %00110000,%01010101
        .byte %01000000,%01010101
        .byte %00100000,%00100101
        .byte %00010000,%01010010
        .byte %01100000,%01010010

        .byte %00000000,%00000000
        .byte %00110000,%01010111
        .byte %01000000,%01010001
        .byte %00100000,%00100010
        .byte %00010000,%01010100
        .byte %01100000,%01010111

        .byte %00000000,%00000000
        .byte %01100000,%01010101
        .byte %01010000,%01010101
        .byte %01100000,%00100101
        .byte %01010000,%01010010
        .byte %01010000,%01010010

        .byte %00000000,%00000000
        .byte %01100000,%01010111
        .byte %01010000,%01010001
        .byte %01100000,%00100010
        .byte %01010000,%01010100
        .byte %01010000,%01010111

        .byte %00000000,%00000000
        .byte %01110110,%01110010
        .byte %01000101,%01000101
        .byte %01100110,%01110101
        .byte %01000101,%01000111
        .byte %01000101,%01110011

        .byte %00000000,%00000000
        .byte %01100010,%01110010
        .byte %01010101,%00100101
        .byte %01010111,%00100111
        .byte %01010101,%00100101
        .byte %01100101,%00100101

; title & help screens
        .include "title.i"
        .include "help.i"

	.cnop	0,$200		; pad to an even number of blocks
