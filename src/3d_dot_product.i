                                    
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


        ;; function:    "dot_product"
        ;;              - used for 3x4 matrix multiplication
        ;;              -> allows to handle 3 and 4 dimensions(last one multiplied by 1)
        ;;              - performs a dot product of 2 3(4)-dimensional vectors
        ;; INPUTS:      - 0 points to topmost element of vector 1
        ;;              - 1 points to topmost element of vector 2
        ;;              - bit "full_dimension" in control
        ;; OUTPUTS:     - A_high/A_low hold 16 bit dot-product


        ;; assumes that all 16 pointers are set
        ;; and that irbk0 = irbk1 = 0
        
dot_product:
        push acc

;; 1

        ld @R0
        st B_high
        ld @R1
        st C_high
        inc 0
        inc 1
        ld @R0
        st B_low
        ld @R1
        st C_low
        inc 0
        dec 1

        callf mul_16bit

        push C_low              ; save result on stack,
        push C_high             ; we have 4 multiplications, but only 3 additions

        set1 psw, irbk0

;; 2

        ld @R0
        st B_high
        ld @R1
        st C_high
        inc 4
        inc 5
        ld @R0
        st B_low
        ld @R1
        st C_low
        inc 4
        dec 5

        callf mul_16bit

        push C_low              ; save result on stack,
        push C_high             ; we have 4 multiplications, but only 3 additions

        clr1 psw, irbk0
        set1 psw, irbk1

;; 3

        ld @R0
        st B_high
        ld @R1
        st C_high
        inc 8
        inc 9
        ld @R0
        st B_low
        ld @R1
        st C_low
        inc 8
        dec 9

        callf mul_16bit

        push C_low              ; save result on stack,
        push C_high             ; we have 4 multiplications, but only 3 additions

        set1 psw, irbk0

        bn control, full_dimension, .skip_4th
;; 4
        ;; this multiplication is always with 1, can be left out


        ld @R1
        st C_high
        inc 13
        ld @R1
        st C_low
        dec 13

        push C_low              ; save result on stack,
        push C_high             ; we have 4 multiplications, but only 3 additions

.skip_4th:
        pop A_high
        pop A_low

        ;; second, compute the sum of 3(4) products using 2(3) additions

        pop B_high
        pop B_low

        ;; inlined "add_16bit"

        ld A_low
        add B_low
        st A_low
        ld A_high
        addc B_high
        st A_high

        pop B_high
        pop B_low

        ;; inlined "add_16bit"

        ld A_low
        add B_low
        st A_low
        ld A_high
        addc B_high
        st A_high

        bn control, full_dimension, .skip_3rd

        pop B_high
        pop B_low

        ;; inlined "add_16bit"

        ld A_low
        add B_low
        st A_low
        ld A_high
        addc B_high
        st A_high

.skip_3rd:

        ;; store result

        ld A_high
        st @R0
        inc 12
        ld A_low
        st @R0
        inc 12

        clr1 psw, irbk0
        clr1 psw, irbk1

        pop acc

        ret





        ;; function:    "dot_product_transposed"
        ;;              - used for point transformation
        ;; INPUTS:      R0 points to 3x4 matrix line (c?1 c?2 c?3 c?4)
        ;;              R1 points to point (x y z 1) with last "1" being omitted
        ;; OUTPUTS:     A_high/A_low - the dot product

dot_product_transposed:
;        push acc
        push 1
;        push count

        mov #3, count           ; first, compute the 3 products
.mul:
        ld @R0
        st B_high
        ld @R1
        st C_high
        inc 0
        inc 1
        ld @R0
        st B_low
        ld @R1
        st C_low
        inc 0
        inc 1

        callf mul_16bit

        push C_low              ; save result on stack,
        push C_high             ; we have 4 multiplications, but only 3 additions

        dbnz count, .mul

        ;; 4th element is always multiplied by 1, skip multiplication

        ld @R0
        st A_high
        inc 0
        ld @R0
        st A_low

        ; second, compute the sum of 4 products using 3 additions

        pop B_high
        pop B_low

        ;; inlined "add_16bit"

        ld A_low
        add B_low
        st A_low
        ld A_high
        addc B_high
        st A_high

        pop B_high
        pop B_low

        ;; inlined "add_16bit"

        ld A_low
        add B_low
        st A_low
        ld A_high
        addc B_high
        st A_high

        pop B_high
        pop B_low

        ;; inlined "add_16bit"

        ld A_low
        add B_low
        st A_low
        ld A_high
        addc B_high
        st A_high

;        pop count
        pop 1
;        pop acc

        ret

