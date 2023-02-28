                                    
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


        ;; function     "scale"
        ;;              - multiplies the current matrix with the following matrix:
        ;;
        ;;             / sx 0  0  0 \
        ;;             | 0  sy 0  0 |
        ;;             | 0  0  sz 0 |
        ;;             \ 0  0  0  1 /
        ;;
        ;; INPUTS:      - sx_high
        ;;              - sx_low
        ;;              - sy_high
        ;;              - sy_low
        ;;              - sz_high
        ;;              - sz_low
        ;;              - R0 points to current matrix
        ;; OUTPUTS:     - current matrix(indirect)

scale_mm:
        push 1

        ;; multiply the scale matrix to the current matrix

        mov #s_start, 1

        bn control, first_mm, .multiply

.copy:
        callf copy_matrix
        bpc control, first_mm, .end     ;; is faster than clr1 plus branch

.multiply:
        callf multiply_matrix

.end:
        pop 1

        ret


        ;; FAST TRANSFORM:      only computes the changing elements of current matrix
        ;;                      -> no need to perform whole matrix multiplication!        
        ;;
        ;; PERFORMS:
        ;;             / c11 c12 c13 c12 \
        ;;  (sx,sy,sz)*| c21 c22 c23 c24 |
        ;;             \ c31 c32 c33 c34 /

scale:
        push acc
        push 1
        push count

        ;; multiplies each of the 3 lines with a scale factor

        ld 0
        st 1

        ;; perform x-axis scaling

                ;; load scale factor

        ld sx_high
        st B_high
        ld sx_low
        st B_low

        mov #4, count

.multiply_sx:

                ;; load multiplicand

        ld @R1
        st C_high
        inc 1
        ld @R1
        st C_low

        callf mul_16bit

                ;; store result

        ld C_low
        st @R1
        dec 1
        ld C_high
        st @R1
        inc 1
        inc 1

        dbnz count, .multiply_sx


        ;; perform y-axis scaling

                ;; load scale factor

        ld sy_high
        st B_high
        ld sy_low
        st B_low

        mov #4, count

.multiply_sy:

                ;; load multiplicand

        ld @R1
        st C_high
        inc 1
        ld @R1
        st C_low

        callf mul_16bit

                ;; store result

        ld C_low
        st @R1
        dec 1
        ld C_high
        st @R1
        inc 1
        inc 1

        dbnz count, .multiply_sy


        ;; perform z-axis scaling

                ;; load scale factor

        ld sz_high
        st B_high
        ld sz_low
        st B_low

        mov #4, count

.multiply_sz:

                ;; load multiplicand

        ld @R1
        st C_high
        inc 1
        ld @R1
        st C_low

        callf mul_16bit

                ;; store result

        ld C_low
        st @R1
        dec 1
        ld C_high
        st @R1
        inc 1
        inc 1

        dbnz count, .multiply_sz

        ;; otherwise these transforms would be simply overwritten
        ;; by first multiplied matrix

        clr1 control, first_mm

        pop count
        pop 1
        pop acc

        ret

