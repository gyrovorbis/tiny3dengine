                                    
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


        ;; trigonometric functions

        ;; function:    "sincos"
        ;;              - computes sine and cosine values using the sinetable
        ;;              - accepts 2's complement 16 bit angles
        ;; INPUTS:      - R1: points to high byte of 2's complement angle
        ;; OUTPUTS:     - sin_high
        ;;              - sin_low
        ;; MODIFIES:    - bit sign of control

sincos:
        push offset
        push trl
        push trh
        ld @R1
        push acc
        inc 1
        ld @R1
        push acc
        dec 1
        push 1

        ;; both sine and cosine are fetched from the same table
        
        mov #<sinetable, trl
        mov #>sinetable, trh

        ;; first take sine into account, later extract cosine from resulting angle

        ;; examine the angle and transform to 0 - 90 degrees range

                ;; sign first

        clr1 control, sign_sin  ; remember the sign of the angle for later
        ld @R1
        bn acc, 7, .positive1
        set1 control, sign_sin
        ;clr1 acc, 7
        inc 1
        callf twos_complement_16bit

.positive1:

                ;; transform to 0 - 360 degrees range

                        ;; perform angle - 360 as long as this is a positive value

        ld @R1
        st A_high
        inc 1
        ld @R1
        st A_low
        mov #$01, B_high
        mov #$68, B_low

.proceed:
        callf sub_16bit

        bp A_high, 7, .leave

                ;; save the last positive value

        ld A_low
        st @R1
        dec 1
        ld A_high
        st @R1
        inc 1

        br .proceed

.leave:
        dec 1


                ;; transform to 0 - 180 degrees range

                        ;; if |angle| > 180 degrees, sub 180


        ld @R1
        st A_high
        inc 1
        ld @R1
        st A_low
        mov #$00, B_high
        mov #$B4, B_low

        callf sub_16bit

        clr1 control, sign_cos
        bp A_high, 7, .negative1
        mov #A_low, 1
        not1 control, sign_sin
        not1 control, sign_cos

.negative1:
                        ;; R1 now points to low 8 bits of angle

                ;; transform to 0 - 90 degrees range
                        
                        ;; mirror at 90 degrees
                        ;; perform 180 - angle if it's over 90 degrees

        ld @R1
        sub #90
        bp acc, 7, .negative2
        mov #180, acc
        sub @R1
        st @R1
        not1 control, sign_cos

.negative2:

        ;; compute address in sinetable

        ld @R1
        add acc
        st offset               ; flashrom address offset:
                                ; every entry in sinetable got 2 bytes

        ;; get the data from the sinetable

        ldc
        st sin_high
        inc offset
        ld offset
        ldc
        st sin_low

        ;; handle sign of the angle

        bn control, sign_sin, .positive2
                                ; sin(-angle) = -sin(angle)
        ;; compute 2's complement
        push 1

        mov #sin_low, 1
        callf twos_complement_16bit

        pop 1

.positive2:

;; now cosine:

        mov #90, acc
        sub @R1

        add acc
        st offset               ; flashrom address offset:
                                ; every entry in sinetable got 2 bytes

        ;; get the data from the sinetable

        ldc
        st cos_high
        inc offset
        ld offset
        ldc
        st cos_low

        ;; handle sign of the angle

        bn control, sign_cos, .positive3
                                ; sin(-angle) = -sin(angle)
        ;; compute 2's complement
        mov #cos_low, 1
        callf twos_complement_16bit

.positive3:
        pop 1
        inc 1
        pop acc
        st @R1
        dec 1
        pop acc
        st @R1
        pop trh
        pop trl
        pop offset

        ret


        ;; the sinetable to provide values for rotation matrix creation
sinetable:
        include"sinetable.i"

