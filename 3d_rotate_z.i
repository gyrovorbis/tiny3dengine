                                    
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


        ;; function     "rotate_z"
        ;;              - multiplies the current matrix with the following matrix:
        ;;
        ;;             / cos(angle) -sin(angle) 0 0 \
        ;;             | sin(angle) cos(angle)  0 0 |
        ;;             | 0          0           1 0 |
        ;;             \ 0          0           0 1 /
        ;;
        ;; INPUTS:      - ax_high, ax_low: angle, 2's complement degree amount
        ;;              - R0 points to current matrix
        ;; OUTPUTS:     - current matrix(indirect)

rotate_z_mm:
        push acc
        push 1

        ;; first get sine and cosine values

        mov #az_high, 1
        callf sincos

        ;; and insert the values into the rotation matrix

        ld cos_high
        st rz_c1_high
        st rz_c2_high
        ld cos_low
        st rz_c1_low
        st rz_c2_low
        ld sin_high
        st rz_s_high
        ld sin_low
        st rz_s_low

                ;; compute 2's complement!!!

        mov #sin_low, 1
        callf twos_complement_16bit

        ld sin_high
        st rz_ns_high
        ld sin_low
        st rz_ns_low

        ;; second multiply the z-axis rotation matrix to the current matrix

        mov #rz_start, 1

        bn control, first_mm, .multiply

.copy:
        callf copy_matrix
        bpc control, first_mm, .end     ;; is faster than clr1 plus branch

.multiply:
        callf multiply_matrix

.end:
        pop 1
        pop acc

        ret


        ;; FAST TRANSFORM:      only computes the changing elements of current matrix
        ;;                      -> no need to perform whole matrix multiplication!
        ;;                      - inlined add_16bit/sub_16bit
        ;;
        ;; PERFORMS:
        ;;             / c*c11-s*c21 c*c12-s*c22 c*c13-s*c23 c*c14-s*c24 \
        ;;             | c*c21+s*c11 c*c22+s*c12 c*c23+s*c13 c*c24+s*c14 |
        ;;             \ c31         c32         c33         c34         /

rotate_z:
        push acc
        push 1
        push count
        push b

        ;; first: get sine and cosine values

        mov #az_high, 1
        callf sincos

        ;; second: compute the products

                ;; let R1 point to first elements high 8 bits of first row

        ld 0
        st 1
        
                ;; let R4 point to cosine products
                ;; and R5 point to sine products

        mov #temp_storage, acc
        st 4
        add #16
        st 5

        mov #8, count

.next_element1:
                ;; load matrix element

        ld @R1
        st B_high
        inc 1
        ld @R1
        st B_low
        inc 1

;        ld B_high
;        st c
;        ld B_low
;        st b
;
;.test:
;        br .test

        set1 psw, irbk0

                ;; perform cosine product

        ld cos_high
        st C_high
        ld cos_low
        st C_low

        callf mul_16bit

        ld C_high
        st @R0
        inc 4
        ld C_low
        st @R0
        inc 4

                ;; perform sine product

        ld sin_high
        st C_high
        ld sin_low
        st C_low

        callf mul_16bit

        ld C_high
        st @R1
        inc 5
        ld C_low
        st @R1
        inc 5

        clr1 psw, irbk0

        dbnz count, .next_element1


        ;; third: perform adds and subs and insert the data into the current matrix

        ;; 2nd row right to left:

                ;; let R1 point to last elements low 8 bit of 2nd row of current matrix

        ld 0
        add #15
        st 1

                ;; let R4 point to cosine products c*c24....c*c21
                ;; and R5 point to sine products   s*c14....s*c11

        mov #temp_storage, acc
        add #15
        st 4
        add #8
        st 5

        mov #4, count

.next_element2:
                ;; load operands add and store

        set1 psw, irbk0

        clr1 psw, cy

        ld @R0
        add @R1
        st b
        dec 4
        dec 5
        ld @R0
        addc @R1
        dec 4
        dec 5

        clr1 psw, irbk0

        dec 1
        st @R1
        inc 1
        ld b
        st @R1
        dec 1
        dec 1

        dbnz count, .next_element2

        ;; 1st row:

                ;; let R5 point to sine products   s*c24....s*c21

        mov #temp_storage, acc
        add #31
        st 5


        mov #4, count

.next_element3:
                ;; load operands, sub and store

        set1 psw, irbk0

        clr1 psw, cy

        ld @R0
        sub @R1
        st b
        dec 4
        dec 5
        ld @R0
        subc @R1
        dec 4
        dec 5

        clr1 psw, irbk0

        dec 1
        st @R1
        inc 1
        ld b
        st @R1
        dec 1
        dec 1

        dbnz count, .next_element3
        
        ;; otherwise these transforms would be simply overwritten
        ;; by first multiplied matrix

        clr1 control, first_mm

        pop b
        pop count
        pop 1
        pop acc

        ret

