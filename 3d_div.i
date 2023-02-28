                                    
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


        ;; function:    "div_16bit" - 8.8 bits fixed point
        ;;              - performs nonrestoring division of 2
        ;;                16bit integers C_x(dividend) and B_x(divisor)
        ;;                in 2's complement form
        ;;              - result is a 16 bit quotient stored in C_x and remainder in A_x,
        ;; INPUTS:      - C_high, dividend
        ;;              - C_low
        ;;              - B_high, divisor
        ;;              - B_low
        ;; OUTPUTS:     - A_high, remainder
        ;;              - A_low
        ;;              - C_high, quotient
        ;;              - C_low
        ;; MODIFIES:    - bit sign in control

div_16bit_slow:
        push acc
        push count
        push 1

; skipped for fixed point compatibility,
;        ;; initialisation:
;        xor acc                 ; clear A
;        st A_low
;        st A_high

        ;; now check for negative arguments
        clr1 control, sign

        ;; look if dividend is negative
        bn C_high, 7, .skip0
        not1 control, sign
        mov #C_low, 1
        callf twos_complement_16bit

.skip0:
        ;; look if divisor is negative
        bn B_high, 7, .skip1
        not1 control, sign
        mov #B_low, 1
        callf twos_complement_16bit

.skip1:
        ;; now shift the divident left to provide fixed point compatibility
        ld C_high
        st A_low
        ld C_low
        st C_high
        xor acc                 
        st C_low
        st A_high

        mov #16, count          ; work on 16 bits

.shiftloop:
        ; don't care what's shifted in
        ld C_low                ; left shift A, Q (accumulator and dividend)
        rolc
        st C_low
        ld C_high
        rolc
        st C_high
        ld A_low
        rolc
        st A_low
        ld A_high
        rolc
        st A_high

;        clr1 psw, cy            ; don't influence later subs/adds

;        bp A_high, 7, .negative0 ; A < 0? now look at the sign of the accumulator
        bp psw, cy, .negative0  ; A < 0? now look at the sign of the accumulator

.positive0:
        callf sub_17bit         ; A = A - M

;        bp A_high, 7, .negative1 ; A < 0? now look at the sign of the accumulator
        bp psw, cy, .negative1  ; A < 0? now look at the sign of the accumulator

.positive1:
        set1 C_low, 0           ; Q(0) = 1

        dbnz count, .shiftloop

        br .finished

.negative0:
        callf add_17bit         ; A = A + M

;        bn A_high, 7, .positive1 ; A < 0? now look at the sign of the accumulator
        bn psw, cy, .positive1  ; A < 0? now look at the sign of the accumulator

.negative1:
        clr1 C_low, 0           ; Q(0) = 1

        dbnz count, .shiftloop

.finished:
;        bn A_high, 7, .end0      ; A < 0? now look at the sign of the accumulator
        bn psw, cy, .end0        ; A < 0? now look at the sign of the accumulator
        callf add_16bit         ; A = A + M

.end0:
        bn control, sign, .end1
        mov #C_low, 1
        callf twos_complement_16bit

.end1:
        pop 1
        pop count
        pop acc

        ret


        ;; use VM's multiplication function to speed up
        ;; discards divisor's low 8 bits, don't cares about remainder


div_16bit:
        push acc
        push b
        push c

        ;; now check for negative arguments
        clr1 control, sign

        ;; look if dividend is negative
        bn C_high, 7, .skip0
        not1 control, sign

        ;; inlined "twos_complement"

        ld C_low
        xor #%11111111
        add #1
        st C_low
        ld C_high
        xor #%11111111
        addc #0
        st C_high

.skip0:
        ;; look if divisor is negative
        bn B_high, 7, .skip1
        not1 control, sign

        ;; inlined "twos_complement"

        ld B_low
        xor #%11111111
        add #1
        st B_low
        ld B_high
        xor #%11111111
        addc #0
        st B_high

.skip1:

        ;; instead of providing 8.8 fixed point compliency
        ;; by multiplying the dividend with 256(left shift of 8 bits),
        ;; devide the divisor by 256(right shift of 8 bits)

        ld B_high
        st b
        ld C_low
        st c
        ld C_high

        div

        ;; we have to check if remainder / B_low >= high 8 bit quotient
        ;; otherwise the result needs to be corrected(recomputed)

        push c
        push acc

                ;; prepare division

        mov #0, c
        ld B_low
        xch b

        div

        pop b
        sub b           ;; only compare integer portion

        pop c
        ld b

        bn psw, cy, .correct

                ;; recompute and correct result

        ld B_high
        st b
        inc b           ;; that's the correction
        ld C_low
        st c
        ld C_high

        div

.correct:
        st C_high
        ld c
        st C_low

        bn control, sign, .end

        ;; inlined "twos_complement"
        ld C_low
        xor #%11111111
        add #1
        st C_low
        ld C_high
        xor #%11111111
        addc #0
        st C_high

.end:
        pop c
        pop b
        pop acc

        ret

