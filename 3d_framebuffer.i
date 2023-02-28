                                    
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


        ;; function     "display_framebuffer"
        ;;              - first 192 bytes of workRAM are copied to screen

display_framebuffer:
        push acc
        push c
        push 2
        push xbnk
        push count
        push vrmad1
        push vrmad2
        push vsel

        xor acc
        st vrmad1
        st vrmad2
        st xbnk

        set1 vsel, ince

        callf write_selected_half_of_screen
        inc xbnk
        callf write_selected_half_of_screen

        pop vsel
        pop vrmad2
        pop vrmad1
        pop count
        pop xbnk
        pop 2
        pop c
        pop acc

        ret



        ;; function     "write_selected_half_of_screen"
        ;;              - sets the given bytes to selected half of screen
        ;;              - assumes that ince of vsel is set
        ;; INPUTS:      - xbnk
        ;;              - 96 bytes in work RAM
        ;;              - vrmad1
        ;;              - vrmad2
        ;; OUTPUTS:     - selected bank of XRAM
        ;; MODIFIES:    - c
        ;;              - 2
        ;;              - count
        ;;              - vtrbf
        ;;              - vrmad1(indirect)
        ;;              - vrmad2(indirect)
        ;;              - vlreg(indirect)

write_selected_half_of_screen:
        mov #8, count                   ;; # of line pairs to write
        mov #$7C, 2                     ;; starting address
.next_two_lines:
        mov #12, c
        ld 2                            ;; adjust XRAM pointer to next two lines
        add #4
        st 2
.next_byte:
        ld vtrbf
        st @R2
        inc 2
        dbnz c, .next_byte
        dbnz count, .next_two_lines

        ret



        ;; function     "clear_framebuffer"
        ;;              - first 192 bytes of workRAM are set to zero


clear_framebuffer:
        push acc
        push vsel
        push vrmad1
        push vrmad2

        clr1 vsel, ince         ; we are not using auto increment
        mov #191, vrmad1
        xor acc
        st vrmad2

.next_byte:
        st vtrbf
        dbnz vrmad1, .next_byte

        st vtrbf

        pop vrmad2
        pop vrmad1
        pop vsel
        pop acc

        ret

