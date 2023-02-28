                                    
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


        ;; function:    "mul_16bit" - 8.8 bits fixed point
        ;;              - performs multiplication of 2 16bit integers C_x and B_x
        ;;                in 2's complement form
        ;;              - result is a 32 bit integer stored in A_x and C_x,
        ;;                C_x being the low 16 bits and A_x the high 16 bits
        ;; INPUTS:      - C_high        multiplier
        ;;              - C_low
        ;;              - B_high        multiplicand
        ;;              - B_low
        ;; OUTPUTS:     - A_high, msb is msb of product
        ;; !! C_x !!    - A_low
        ;;              - C_high
        ;;              - C_low, lsb is lsb of product
        ;; MODIFIES:    - bit sign in control

        ;; use VM's multiplication function to speed up
        ;; !! use free space in SFR area in RAM for temporary storage

mul_16bit:
        push acc
        push b
        push c

        ;; now check for negative arguments
        clr1 control, sign

        ;; look if multiplier is negative
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
        ;; look if multiplicand is negative
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
        ;; start to multiply low 8 bits of multiplicand

        ld B_low
        st b
        ld C_low
        st c
        ld C_high

        mul

        ;; for being 8.8 fixed point complient,
        ;; we discard the low 8 bits in c
        ;; and only use b,acc

        st T_low
        ld b
        st T_high

        ;; now multiply the high 8 bits of the multiplicand

        ld B_high
        st b
        ld C_low
        st c
        ld C_high

        mul

        ;; for being 8.8 fixed point complient,
        ;; we discard the high 8 bits in b
        ;; and only use acc, c

        ;; have to add previous result

        st b
        ld c
        add T_low
        st C_low

        ld b
        addc T_high
        st C_high

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

