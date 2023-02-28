                                    
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


        ;; function     "draw_line"
        ;;              - implements Bresenham's algorithm for fast drawing
        ;; INPUTS:      - point1_x, 
        ;;              - point1_y,
        ;;              - point2_x, 
        ;;              - point2_y point coordinates

draw_line:
        push acc
        push b
        push c
        push count
        push vsel
        push vrmad1
        push vrmad2

        mov #0, count

        ;; initially set dx, dy, x and y

.begin:
        ld point2_x
        st c                    ; c = x_1
        sub point1_x
        bn psw, cy, .normal     ; if dx < 0, switch points
        clr1 psw, cy
;        ld point1_y                     ; switch y components
;        st b
;        ld point2_y
;        st point1_y
;        ld b
;        st point2_y

;        ld point1_x                     ; switch x components
;        st point2_x
;        ld c
;        st point1_x

        ld point1_y                     ; switch y components
        xch point2_y
        st point1_y

        ld point1_x                     ; switch x components
        xch point2_x
        st point1_x

        br .begin                       ; recompute dx

.normal:
        st dx             ; point2_x = dx, point1_x = x
        st t                    

        ;; init first points work RAM position, save masking bit to b
        ;; and make sure that workRAM pointers don't increase automatically

        bp control, fast_polyline, .get_values
        callf adress_workRAM
        br .store

.get_values:
        ld T_vrmad1
        st vrmad1
        xor acc
        ;ld T_vrmad2
        st vrmad2
        ld T_b

;;;;;
;        ld T_vrmad1
;        st b
;        st c
;        ld T_b
;.test:
;
;        br .test
;;;;;;
.store:
        st b
        clr1 vsel, ince        

        ;; seperate 4 methods
        ;; first check if dy >= 0

        ;; adjusting to draw_point's coordinate system
        ld point1_y
        sub point2_y
        bp psw, cy, .method_2_3
        st dy             ; point2_y = dy, point1_y = y

.method_0_1:
        ;; dy >= 0
        ;;
        ;; |
        ;; |
        ;; |
        ;; |____
        ;;

        ;; now check if dy > dx
        ld dx
        sub dy
        bn psw, cy, .method_1

.method_0:
        ;; dy > dx
        ;; => 1 < m
        ;;
        ;; |   /
        ;; |  /
        ;; | /
        ;; |/
        ;;

        ;; recompute point2_y
        ld point1_y
        sub dy
        st c

        callf method0
        br .end

.method_1:
        ;; dy <= dx
        ;; => 0 <= m <= 1
        ;;
        ;;     /
        ;;    /
        ;;   /
        ;;  /
        ;;  ----

        callf method1
        br .end

.method_2_3:
        ;; dy < 0
        ;;  ____
        ;; |
        ;; | 
        ;; |
        ;; |
        ;;

        ld dy           ; now dy is positive again
        sub y
        st dy

        ;; now check if dy > dx
        ld dx
        sub dy
        bp psw, cy, .method_3

.method_2:
        ;; dy <= dx
        ;; => -1 <= m < 0
        ;;
        ;; ____
        ;; \
        ;;  \
        ;;   \
        ;;    \
        ;;

        callf method2
        br .end

.method_3:
        ;; dy > dx
        ;; => m < -1
        ;;
        ;; |\
        ;; | \
        ;; |  \
        ;; |   \
        ;;

        ;; recompute point2_y
        ld point1_y
        add dy
        st c

        callf method3

.end:
        ;; for fast polyline drawing: save position

        ld vrmad1
        st T_vrmad1
        ld vrmad2
        st T_vrmad2
        ld b
        st T_b

        pop vrmad2
        pop vrmad1
        pop vsel
        pop count
        pop c
        pop b
        pop acc

        ret



        ;; 1 < m
        ;;
        ;; |   /
        ;; |  /
        ;; | /
        ;; |/
        ;;
        ;; bottom up

method0:
.loop:
        ld y             ; while x < x_1
        be c, .end

        ; mark
        ld b
        or vtrbf
        st vtrbf

        ;; adjusting to draw_point's coordinate system
        dec y                   ; x := x + 1
;; adjust work RAM adress
        ld vrmad1
        sub #6
        st vrmad1

        ld t                    ; t := t - 2dx
        sub dx
        bn psw, cy, .continue   ; IF t < 0 part1
        set1 count, 0

.continue:
        sub dx
        st t
        bpc count, 0, .increase
        bn psw, cy, .loop       ; IF t < 0 part2
                                ; THEN
.increase:
        ;; adjusting to draw_point's coordinate system
        inc x                           ; y := y + 1
;; adjust work RAM adress
        ld b
        ror
        st b
        bn b, 7, .in_byte
        inc vrmad1

.in_byte:

        ld t                            ; t := t + 2dy
        add dy
        add dy
        st t
        br .loop
.end:
        ; mark
        ld b
        or vtrbf
        st vtrbf

        ret



        ;; 0 <= m <= 1
        ;;
        ;;     /
        ;;    /
        ;;   /
        ;;  /
        ;;  ----
        ;; left to right

method1:
.loop:
        ld x             ; while x < x_1
        be c, .end

        ; mark
        ld b
        or vtrbf
        st vtrbf

        inc x                   ; x := x + 1
;; adjust work RAM adress
        ld b
        ror
        st b
        bn b, 7, .in_byte
        inc vrmad1

.in_byte:

        ld t                    ; t := t - 2dy
        sub dy
        bn psw, cy, .continue   ; IF t < 0 part1
        set1 count, 0

.continue:
        sub dy
        st t
        bpc count, 0, .increase
        bn psw, cy, .loop       ; IF t < 0 part2
                                ; THEN
.increase:
        ;; adjusting to draw_point's coordinate system
        dec y                           ; y := y + 1
;; adjust work RAM adress
        ld vrmad1
        sub #6
        st vrmad1

        ld t                            ; t := t + 2dx
        add dx
        add dx
        st t
        br .loop
.end:
        ; mark
        ld b
        or vtrbf
        st vtrbf

        ret



        ;; -1 <= m < 0
        ;;
        ;; ____
        ;; \
        ;;  \
        ;;   \
        ;;    \
        ;;
        ;; left to right

method2:
.loop:
        ld x             ; while x < x_1
        be c, .end

        ; mark
        ld b
        or vtrbf
        st vtrbf

        inc x                   ; x := x + 1
;; adjust work RAM adress
        ld b
        ror
        st b
        bn b, 7, .in_byte
        inc vrmad1

.in_byte:

        ld t                    ; t := t - 2dy
        sub dy
        bn psw, cy, .continue   ; IF t < 0, part1
        set1 count, 0

.continue:
        sub dy
        st t
        bpc count, 0, .increase
        bn psw, cy, .loop       ; IF t < 0, part2
                                ; THEN
.increase:
        ;; adjusting to draw_point's coordinate system
        inc y                           ; y := y + 1
;; adjust work RAM adress
        ld vrmad1
        add #6
        st vrmad1

        ld t                            ; t := t + 2dx
        add dx
        add dx
        st t
        br .loop
.end:
        ; mark
        ld b
        or vtrbf
        st vtrbf

        ret



        ;; -1 > m
        ;;
        ;; |\
        ;; | \
        ;; |  \
        ;; |   \
        ;;
        ;; top down

method3:
.loop:
        ld y             ; while x < x_1
        be c, .end

        ; mark
        ld b
        or vtrbf
        st vtrbf

        ;; adjusting to draw_point's coordinate system
        inc y                   ; x := x + 1
;; adjust work RAM adress
        ld vrmad1
        add #6
        st vrmad1

        ld t                    ; t := t - 2dy
        sub dx
        bn psw, cy, .continue   ; IF t < 0 part1
        set1 count, 0

.continue:
        sub dx
        st t
        bpc count, 0, .increase
        bn psw, cy, .loop       ; IF t < 0 part2
                                ; THEN
.increase:
        ;; adjusting to draw_point's coordinate system
        inc x                           ; y := y + 1
;; adjust work RAM adress
        ld b
        ror
        st b
        bn b, 7, .in_byte
        inc vrmad1

.in_byte:
        ld t                            ; t := t + 2dy
        add dy
        add dy
        st t
        br .loop
.end:
        ; mark
        ld b
        or vtrbf
        st vtrbf

        ret

