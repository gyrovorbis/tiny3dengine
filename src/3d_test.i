                                    
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


        ;; TEST FUNCTIONS


test_draw_point:
        callf clear_framebuffer

        mov #0, point1_x
        mov #0, point1_y
        mov #32, count

.next_point:
        callf draw_point
        inc point1_x
        inc point1_y
        dbnz count, .next_point

        callf display_framebuffer

        ret

test_draw_line:
        callf clear_framebuffer

        mov #0, point1_x
        mov #0, point1_y
        mov #20, point2_x
        mov #31, point2_y

        callf draw_line

        callf display_framebuffer

        ret



test_add_16bit:
        mov #%10101011, A_low
        mov #%10101010, A_high
        mov #%01010101, B_low
        mov #%01010101, B_high

        mov #0, xbnk
        mov #$80, 2

        callf add_16bit

        bn psw, cy, .no_overflow
        mov #%10000001, @R2

.no_overflow:
        inc 2
        ;; display result
        ld A_high
        st @R2
        inc 2
        ld A_low
        st @R2

        ret


test_mul_16bit_compare:
        push acc
        push 1
        push 2
        push xbnk

        ;; activate RC clock 600/6 = 100 kHz
        clr1 ocr, mainclk       ; disable MAIN clock
        set1 ocr, mainctl       ; stop MAIN clock
        set1 ocr, halfclk       ; set frequency divisor to 6
        clr1 ocr, rcctl         ; start RC oscillator
        clr1 ocr, subclk        ; enable RC clock

        ;; init operands

        xor acc
        st B_high
        st B_low
        st C_high
        st C_low
.next_C:
        ;; reset multiplicand

;        xor acc
;        st B_high
;        st B_low


.next_B:
        ;; perform the 2 multiplications and compare

                ;; store/display current operands


        mov #0, xbnk
        mov #$80, 2


        ld C_high
        st tx_high
        st @R2
        inc 2
        ld C_low
        st tx_low
        st @R2
        inc 2
        inc 2
        ld B_high
        st ty_high
        st @R2
        inc 2
        ld B_low
        st ty_low
        st @R2

                ;; perform slow and correct? multiplication

;        callf mul_16bit_slow

        ld C_high
        st sx_high
        ld C_low
        st sx_low

                ;; reload operands

        ld tx_high
        st C_high
        ld tx_low
        st C_low

        ld ty_high
        st B_high
        ld ty_low
        st B_low

                ;; perform fast and error prone? multiplication
        
        callf mul_16bit

        ld C_high
        st sy_high
        ld C_low
        st sy_low

                ;; compare results

        ld sx_low
        bne sy_low, .error

        ld sx_high
        bne sy_high, .error

                ;; reload operands

        ld tx_high
        st C_high
        ld tx_low
        st C_low

        ld ty_high
        st B_high
        ld ty_low
        st B_low

        ;; increase multiplicand

        mov #B_low, 1
        callf inc_16bit

        ;; if zero, increase multiplier

        ld B_low
        bnz .next_B

        ld B_high
        bnz .next_B

.proceed:
        ;; increase multiplier

        mov #C_low, 1
        callf inc_16bit

        ;; if zero, finished

        ld C_low
        bnz .next_C

        ld C_high
        bnz .next_C

        br .end

.error:
        ;; display results left, operands right

        mov #0, xbnk
        mov #$80, 2

        ld sx_high             ;; slow multiplication result top left
        st @R2
        inc 2
        ld sx_low
        st @R2
        inc 2

        inc 2
        ld tx_high
        st @R2
        inc 2
        ld tx_low
        st @R2

        ;; 2nd line

        inc 2
        inc 2                   
        ld sy_high             ;; fast multiplication result bottom left
        st @R2
        inc 2
        ld sy_low
        st @R2
        inc 2

        inc 2
        ld ty_high
        st @R2
        inc 2
        ld ty_low
        st @R2

                ;; underline        

        mov #$90, 2
        mov #$FF, acc
        st @R2
        inc 2
        st @R2
        inc 2
        inc 2
        st @R2
        inc 2
        st @R2

.wait:
        callf getkeys
        be #$FF, .wait
        br .proceed

.end:
        pop xbnk
        pop 2
        pop 1
        pop acc

        ret


test_mul_16bit:
        mov #%00000001, C_high
        mov #%00000000, C_low
        mov #%00000001, B_high
        mov #%00000000, B_low

        callf mul_16bit

        ;; display result
        mov #0, xbnk
        mov #$80, 2
        ld A_high
        st @R2
        inc 2
        ld A_low
        st @R2
        inc 2
        inc 2
        ld C_high
        st @R2
        inc 2
        ld C_low
        st @R2


        mov #$FF, acc
        inc 2
        inc 2
        st @R2
        inc 2
        st @R2
        inc 2
;        st @R2
        inc 2
        st @R2
        inc 2
        st @R2


;        mov #$86, 2
;        mov #4, count
;        
;.loop:
;        mov #$FF, @R2
;        inc 2
;
;        dbnz count, .loop


        ret



test_div_16bit_compare:
        push acc
        push 1
        push 2
        push xbnk

        ;; activate RC clock 600/6 = 100 kHz
        clr1 ocr, mainclk       ; disable MAIN clock
        set1 ocr, mainctl       ; stop MAIN clock
        set1 ocr, halfclk       ; set frequency divisor to 6
        clr1 ocr, rcctl         ; start RC oscillator
        clr1 ocr, subclk        ; enable RC clock

        ;; init operands

        xor acc
        st B_high
        st B_low
        st C_high
        st C_low
.next_C:
        ;; reset multiplicand

;        xor acc
;        st B_high
;        st B_low


.next_B:
        ;; perform the 2 multiplications and compare

                ;; store/display current operands


        mov #0, xbnk
        mov #$80, 2


        ld C_high
        st tx_high
        st @R2
        inc 2
        ld C_low
        st tx_low
        st @R2
        inc 2
        inc 2
        ld B_high
        st ty_high
        st @R2
        inc 2
        ld B_low
        st ty_low
        st @R2

                ;; perform slow and correct? multiplication

;        callf div_16bit_slow

        ld C_high
        st sx_high
        ld C_low
        st sx_low

                ;; reload operands

        ld tx_high
        st C_high
        ld tx_low
        st C_low

        ld ty_high
        st B_high
        ld ty_low
        st B_low

                ;; perform fast and error prone? multiplication
        
        callf div_16bit

        ld C_high
        st sy_high
        ld C_low
        st sy_low

                ;; compare results

        ld sx_low
        bne sy_low, .error

        ld sx_high
        bne sy_high, .error

                ;; reload operands

        ld tx_high
        st C_high
        ld tx_low
        st C_low

        ld ty_high
        st B_high
        ld ty_low
        st B_low

        ;; increase multiplicand

        mov #B_low, 1
        callf inc_16bit

        ;; if zero, increase multiplier

        ld B_low
        bnz .next_B

        ld B_high
        bnz .next_B

.proceed:
        ;; increase multiplier

        mov #C_low, 1
        callf inc_16bit

        ;; if zero, finished

        ld C_low
        bnz .next_C

        ld C_high
        bnz .next_C

        br .end

.error:
        ;; display results left, operands right

        mov #0, xbnk
        mov #$80, 2

        ld sx_high             ;; slow multiplication result top left
        st @R2
        inc 2
        ld sx_low
        st @R2
        inc 2

        inc 2
        ld tx_high
        st @R2
        inc 2
        ld tx_low
        st @R2

        ;; 2nd line

        inc 2
        inc 2                   
        ld sy_high             ;; fast multiplication result bottom left
        st @R2
        inc 2
        ld sy_low
        st @R2
        inc 2

        inc 2
        ld ty_high
        st @R2
        inc 2
        ld ty_low
        st @R2

                ;; underline        

        mov #$90, 2
        mov #$FF, acc
        st @R2
        inc 2
        st @R2
        inc 2
        inc 2
        st @R2
        inc 2
        st @R2

.wait:
        callf getkeys
        be #$FF, .wait
        br .proceed

.end:
        pop xbnk
        pop 2
        pop 1
        pop acc

        ret


test_div_16bit:

;        mov #%10000000, C_high
;        mov #%00000000, C_low
;        mov #%10000000, B_high
;        mov #%00000101, B_low


; with error:
        mov #%01000000, C_high
        mov #%00000000, C_low
        mov #%01000000, B_high
        mov #%00000101, B_low
;
; remainder: 00000000 01011111
; quotient:  01111111 11101101

; without error:
;        mov #%00100000, C_high
;        mov #%00000000, C_low
;        mov #%00100000, B_high
;        mov #%00000101, B_low
;
; remainder: 00100000 00000000
; quotient   00000000 00000000

        callf div_16bit

        ;; display result
        mov #0, xbnk
        mov #$80, 2
        ld A_high
        st @R2
        inc 2
        ld A_low
        st @R2
        inc 2
        inc 2
        ld C_high
        st @R2
        inc 2
        ld C_low
        st @R2

        mov #$FF, acc
        inc 2
        inc 2
        st @R2
        inc 2
        st @R2
        inc 2
;        st @R2
        inc 2
        st @R2
        inc 2
        st @R2


        ret



test_trigonometrics:

        mov #$1, ax_high 
        mov #$71, ax_low

        mov #ax_high, 1
        callf sincos

        mov #0, xbnk
        mov #$80, 2

        ld sin_high
        st @R2
        inc 2
        ld sin_low
        st @R2
        inc 2
        inc 2
        ld cos_high
        st @R2
        inc 2
        ld cos_low
        st @R2

        mov #$FF, acc
        inc 2
        inc 2
        st @R2
        inc 2
        st @R2
        inc 2
;        st @R2
        inc 2
        st @R2
        inc 2
        st @R2

        ret

;;;;
;        ld sin_high
;        st b
;        ld sin_low
;        st c
;.test:
;        br .test
;;;;

test_put_polygon:
        xor acc                 ; clear translation data
        st tx_low
        st tx_high
        st ty_low
        st ty_high
        st tz_low
        st tz_high
;        st a_x

        mov #$01, sx_high
        mov #$80, sx_low
        mov #$01, sy_high
        mov #$80, sy_low
        mov #$01, sz_high
        mov #$80, sz_low

        mov #>polygon_lines_01, trh
        mov #<polygon_lines_01, trl

.loop:
        callf init_stack

;        ld a_x
;        add #5
;        st a_x

                ;; transform the box center to (0,0,0)

;        mov #$E8, tx_low
;        mov #$FF, tx_high
;        mov #$F0, ty_low
;        mov #$FF, ty_high
;        mov #$F6, tz_low
;        mov #$FF, tz_high
;        callf translate

                ;; scale

        callf scale

                ;; rotate around the self y-axis

;        callf rotate_z

;        mov #temp_matrix, 1
;        callf display_matrix

;.test:
;        br .test

                ;; translate the box back to it's first position

        mov #$18, tx_low
        mov #$00, tx_high
        mov #$10, ty_low
        mov #$00, ty_high
        mov #$1A, tz_low
        mov #$00, tz_high
;        callf translate

        callf clear_framebuffer

        callf put_polygon

        callf display_framebuffer


        ;; for debugging: put last point's coordinates in B and C
;        ld point1_x
;        st b
;        ld point1_y
;        st c

        ;; now look at the current matrix
;        ld 0
;        st 1

        ;; or display the last temporary matrix
;        mov #temp_matrix, 1
;        callf display_matrix

        ;; or the last transformed vector
;        mov #temp_vector, 1
;        callf display_vector


.loop1:
        callf getkeys

        bn acc, pressed_up, .up
        bn acc, pressed_down, .down
        bn acc, pressed_left, .left
        bn acc, pressed_right, .right
        br .loop1

.up:
        ld ty_low
        bne #0, .up1
        dec ty_high


.up1:
        dec ty_low
        br .loop

.down:
        ld ty_low
        bne #$FF, .down1
        inc ty_high

.down1:
        inc ty_low
        br .loop

.left:
        ld tx_low
        bne #0, .left1
        dec tx_high

.left1:
        dec tx_low
        br .loop

.right:
        ld tx_low
        bne #$FF, .right1
        inc tx_high

.right1:
        inc tx_low
        br .loop


        ret




test_transform_matrices
        callf clrscr

        xor acc
        st tx_low
        st ty_low
        st tz_low

        inc acc
;        inc acc
        st tx_high
;        inc acc
;        inc acc
        st ty_high
;        inc acc
;        inc acc
        st tz_high



        callf init_stack

;        ld 0
;        st 1
;        callf transpose_matrix


        
        clr1 control, first_mm        
        callf translate

;        callf translate

        ld 0
        st 1
;        clr1 psw, irbk0
;        clr1 psw, irbk1

;        mov #c1_start, 1
        mov #0, xbnk
        callf display_matrix
        
        mov #t_start, 1
        mov #1, xbnk
        callf display_matrix

        ;; just for sure to see were the current matrix and the temporary matrix are
        mov #c0_start, b
        ld 0
        st c

        ret



test_dot_product:
        callf clrscr

        callf init_stack


        ;; for sure that the vector is not zero
        ld 0
        st 1
        callf display_vector


        set1 control, full_dimension
;        mov #4, dimension
        callf dot_product


        ;; the dot product:
        ld A_high
        st b
        ld A_low
        st c


        ret

