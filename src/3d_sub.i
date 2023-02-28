                                    
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


        ;; function:    "sub_16bit"
        ;;              - performs the subtraction of 2 16 bit integers A_x and B_x
        ;;                in 2's complement form
        ;;              - result is stored in A_x
        ;; CYCLES:      - subroutine: 16 + call = 18 cycles, embedded: 12-14 cycles
        ;; INPUTS:      - A_low
        ;;              - A_high
        ;;              - B_low
        ;;              - B_high
        ;; OUTPUTS:     - A_low
        ;;              - A_high


sub_16bit:
        push acc

        ld A_low
;        clr1 psw, cy
        sub B_low
        st A_low
        ld A_high
        subc B_high
        st A_high

        ;; overflow CAN occur, when one negative number is added to a positive and
        ;; overflow WILL occur, when 2 negative numbers are added
;        bn psw, cy, .no_overflow
;        bp A_high, 7, .no_overflow
        ;; now an overflow has occured
;        clr1 psw, cy

.no_overflow:
        pop acc

        ret




sub_17bit:
        push acc
        push psw

        callf sub_16bit

        ;; set carry bit only when old and new carry bit are different
        pop acc
        xor psw
        clr1 psw, cy

        bn acc, cy, .no_set
        set1 psw, cy

.no_set:
        pop acc
        ret

