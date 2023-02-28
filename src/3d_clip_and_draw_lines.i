                                    
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


        ;; function     "clip_and_draw_lines"
        ;;              - transforms start and end point of a line
        ;;                such that they are on the screen, if possible
        ;; INPUTS:      point1_x, point1_y
        ;;              point2_x, point2_y
        ;; OUTPUTS:     point1_x, point1_y
        ;;              point2_x, point2_y

clip_and_draw_lines:
        push point1_x
        push point1_y
        push point2_x
        push point2_y
        push acc
        push b
        push c

        bn control, no_clipping, .clip1
        brf .skip_v_bottom

.clip1:

        ;; check if vertically outside of screen

                ;; first make sure that left point is in point1_? and right point is in point2_?

        ld point2_y
        sub point1_y
        bn acc, 7, .dont_swap1  ; if dy < 0, switch points
        bp psw, cy, .swap1      ; be aware of negative values
.swap1:
        clr1 psw, cy

        ld point1_y                     ; switch y components
        xch point2_y
        st point1_y

        ld point1_x                     ; switch x components
        xch point2_x
        st point1_x

.dont_swap1:

                ;; check top

                        ;; if point1 is inside, don't check for point2, too

        bn point1_y, 7, .skip_v_top

                        ;; if point2 is also top outside, don't draw line

        bn point2_y, 7, .comp_p1x
        brf .dont_draw

.comp_p1x:
                ;; compute new point1_x

                ;; compute dx/dy

                        ;; compute dy

        ld point2_y
        sub point1_y
        st b

                        ;; compute dx

        ld point2_x
        sub point1_x

        clr1 control, sign
        bn acc, 7, .pos_p1x
        xor #%11111111
        inc acc
        set1 control, sign

.pos_p1x:
        st acc                  ;; take care of rational values
        mov #0, c

        div

                ;; finished: dx/dy

                ;; result remains in c

                        ;; compute number of points to clip away
        push acc

        ld point1_y
        xor #%11111111
        inc acc
;        sub #32
        st b

        pop acc

                        ;; compute x-axis difference

        mul

        st c

        ld point1_x

        sub c
        bp control, sign, .neg_p1x
        add c
        add c
.neg_p1x:
        st point1_x


        ;; and set point1_y

        mov #0, point1_y



.skip_v_top:

                ;; check bottom

                        ;; if point2 is inside, don't check for point1, too

        ld point2_y
        sub #32
        bp psw, cy, .skip_v_bottom

                        ;; check if point2 is right or left

        sub #96
        bn psw, cy, .skip_v_bottom

                        ;; if point1 is also bottom outside, don't draw line

        ld point1_y             ;; on screen check
        sub #32
        bp psw, cy, .comp_p2x
                                
        sub #96                 ;; right outside check
        bn psw, cy, .comp_p2x
        brf .dont_draw

.comp_p2x:
                ;; compute new point2_x

                ;; compute dx/dy

                        ;; compute dy

        ld point2_y
        sub point1_y
        st b

                        ;; compute dx

        ld point2_x
        sub point1_x

        clr1 control, sign
        bn acc, 7, .pos_p2x
        xor #%11111111
        inc acc
        set1 control, sign

.pos_p2x:
        st acc                  ;; take care of rational values
        mov #0, c

        div

                ;; finished: dx/dy

                ;; result remains in c

                        ;; compute number of points to clip away
        push acc

        ld point2_y
;        xor #%11111111
;        inc acc
        sub #31
        st b

        pop acc

                        ;; compute x-axis difference

        mul

        st c

        ld point2_x

        sub c
        bn control, sign, .neg_p2x
        add c
        add c
.neg_p2x:
        st point2_x


        ;; and set point2_y

        mov #31, point2_y

;;;;
        ld point1_x
        st b
        ld point2_x
        st c
        mov #%10101010, acc
.test:
        callf getkeys
        be #$FF, .test
;;;;


.skip_v_bottom:


        ;; check if horizontally outside of screen

                ;; first make sure that left point is in point1_? and right point is in point2_?

        ld point2_x
        sub point1_x
        bn acc, 7, .dont_swap2  ; if dx < 0, switch points
        bp psw, cy, .swap2      ; be aware of negative values
.swap2:
        clr1 psw, cy

        ld point1_y                     ; switch y components
        xch point2_y
        st point1_y

        ld point1_x                     ; switch x components
        xch point2_x
        st point1_x

.dont_swap2:
        bn control, no_clipping, .clip2
        brf .skip_h_right

.clip2:

                ;; check left

                        ;; if point1 is inside, don't check for point2, too

        bn point1_x, 7, .skip_h_left

                        ;; if point2 is also left outside, don't draw line

        bn point2_x, 7, .comp_p1y
        brf .dont_draw

.comp_p1y:

        ;; compute new point1_y

                ;; compute dy/dx

                        ;; compute dx

        ld point2_x
        sub point1_x
        st b

                        ;; compute dy

        ld point2_y
        sub point1_y

        clr1 control, sign
        bn acc, 7, .pos_p1y
        xor #%11111111
        inc acc
        set1 control, sign

.pos_p1y:
        st acc                  ;; take care of rational values
        mov #0, c

        div

                ;; finished: dy/dx

                ;; result remains in c

                        ;; compute number of points to clip away
        push acc

        ld point1_x
        xor #%11111111
        inc acc
;        sub #47
        st b

        pop acc

                        ;; compute y-axis difference

        mul

        st c

        ld point1_y

        sub c
        bp control, sign, .neg_p1x1
        add c
        add c
.neg_p1x1:
        st point1_y


        ;; and set point1_x

        mov #0, point1_x

.skip_h_left:

                ;; check right

                        ;; if point2 is inside, don't check for point1, too

        ld point2_x
        sub #48
        bp psw, cy, .skip_h_right

                        ;; check if point2 is right or left

        sub #80
        bn psw, cy, .skip_h_right

                        ;; if point1 is also right outside, don't draw line

        ld point1_x             ;; on screen check
        sub #48
        bp psw, cy, .comp_p2y
                                
        sub #80                 ;; right outside check
        bp psw, cy, .dont_draw
;        bn psw, cy, .comp_p2y
;        brf .dont_draw

.comp_p2y:
                ;; compute new point2_y

                ;; compute dy/dx

                        ;; compute dx

        ld point2_x
        sub point1_x
        st b

                        ;; compute dy

        ld point2_y
        sub point1_y

        clr1 control, sign
        bn acc, 7, .pos_p2y
        xor #%11111111
        inc acc
        set1 control, sign

.pos_p2y:
        st acc                  ;; take care of rational values
        mov #0, c

        div

                ;; finished: dy/dx

                ;; result remains in c

                        ;; compute number of points to clip away
        push acc

        ld point2_x
;        xor #%11111111
;        inc acc
        sub #47
        st b

        pop acc

                        ;; compute y-axis difference

        mul

        st c

        ld point2_y

        sub c
        bn control, sign, .neg_p2y
        add c
        add c
.neg_p2y:
        st point2_y


        ;; and set point2_x

        mov #47, point2_x


.skip_h_right:



        callf draw_line

.dont_draw:
        pop c
        pop b
        pop acc
        pop point2_y
        pop point2_x
        pop point1_y
        pop point1_x

        ret

