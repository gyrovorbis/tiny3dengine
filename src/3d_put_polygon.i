                                    
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


        ;; polygon data format in flashrom:
        ;;
        ;; byte offset:         comment:
        ;; 00                   option header
        ;; :                    header format:
        ;; :                    value:               comment:
        ;; :                    %0000000             points
        ;; :                    %0000001             polyline
        ;; :                    %0000010             lines
        ;; :                    %0000011             polylines
        ;; 01                   number of points following
        ;; :                    number of points format:
        ;; :                    1-32                 maximum of points the workRAM can hold(projected, 2x8bits)
        ;; :                    1-42                 ensures that "number of lines" can be addressed
        ;; :                                         using offset(1 byte) only
        ;; :
        ;; :
        ;; 1+6n                 x_high
        ;; 1+6n+1               x_low
        ;; 1+6n+2               y_high
        ;; 1+6n+3               y_low
        ;; 1+6n+4               z_high
        ;; 1+6n+5               z_low
        ;; :
        ;; :
        ;; m                    number of lines following
        ;; :                    number of lines format:
        ;; :                    0-127                ensures that all lines can be addressed
        ;; :                                         using offset(1 byte) only
        ;; :
        ;; :
        ;; m+2k                 first point(index) of k-th line
        ;; m+2k+1               second point(index) of k-th line
        ;; :                            and first point of k+1-th line
        ;; :                    second point of k+1-th line
        ;; :                            and first point of k+2-th line
        ;; :
        ;; :
        ;;
        ;;
        ;; workRAM usage for transformed and projected points
        ;; byte offset:
        ;; 192                  point1_x
        ;; 193                  point1_y
        ;;  :
        ;;  :
        ;;  :
        ;; 254                  point32_x
        ;; 255                  point32_y


        ;; function:            "put_polygon"
        ;;                      - draws the given polygon structure into framebuffer
        ;;                      -> performs coordinate transformation of all points using current matrix
        ;;                      -> performs perspective projection
        ;;                      -> draws points/polylines into framebuffer                        
        ;; INPUTS:              - trh/trl, flashrom address of polygon data
        ;;

put_polygon:
        push acc
        push count
        push c
        push 1
        push vsel
        push vrmad1
        push vrmad2

;; 1. transform all points of the object to screen coordinates

        ;; prepare to transform all points

                ;; init workRAM

        set1 vsel, ince         ; we are using auto increment
        mov #192, vrmad1
        xor acc
        st vrmad2

                ;; extract header and number of points
        ldc
        st header
        mov #1, acc
        ldc
        st npoints
        st count

        ;; now start transforming all points

        mov #2, offset

.next_point:
                ;; get one point

        mov #6, c
        mov #temp_vector, 1

.next_byte:
        ld offset
        ldc
        st @R1
        inc offset
        inc 1

        dbnz c, .next_byte

                ;; transform that point to world coordinate system

        mov #temp_vector, 1
        ;; assume that R0 allready points to current matrix
        callf transform_point

                ;; now do the projection

        callf project_point

        dbnz count, .next_point

;; 2. Draw all visible things to the screen

        ;; prepare
        
                ;; reinit workRAM pointers

        mov #192, vrmad1

                ;; get number of points

        ld npoints
        st count

        ;; evaluate header to determine data type

        ld header


        bne #0, .polyline

.point:
        ;; it's a collection of points

                ;; check if at least one point is there

        ld count
        bnz .next_point2
        brf .end

                ;; if so, display them all

.next_point2:
        ld vtrbf
        st point1_x
        ld vtrbf
        st point1_y

                ;; check for visibility
                ;; bounds should be:
                ;; 0 <= point1_x <= 47
                ;; 0 <= point1_y <= 31

        ld point1_x
        sub #48
        bn psw, cy, .skip

        ld point1_y
        sub #32
        bn psw, cy, .skip


        callf draw_point
        mov #0, vrmad2          ; refresh for softvms

.skip:
        dbnz count, .next_point2

        brf .end

.polyline:

        bne #1, .lines

        ;; it's a polyline

                ;; check if at least 2 points are available

        ld count
        and #%11111110
        bnz .proceed
        brf .end

.proceed:

                ;; draw a line(n-1) between all neighboring points(n)

        dec count

        ld vtrbf
        st point2_x
        ld vtrbf
        st point2_y

        clr1 control, fast_polyline

.next_point3:
                ;; copy over old point

        ld point2_x
        st point1_x
        ld point2_y
        st point1_y

                ;; and add a new point

        ld vtrbf
        st point2_x
        ld vtrbf
        st point2_y

        callf clip_and_draw_lines

;        callf draw_line
        mov #0, vrmad2          ; refresh for softvms

;        set1 control, fast_polyline

        dbnz count, .next_point3

        clr1 control, fast_polyline

        brf .end

.lines:

        bne #2, .polylines

        ;; it's a collection of lines

                ;; get number of lines

        ld offset
        ldc
        st nlines

                ;; start line drawing loop
.nextline:
                        ;; get first point

        inc offset
        ld offset
        ldc
        add acc         ;; every point has 2 bytes
        add #192
        st vrmad1
        ld vtrbf
        st point1_x
        ld vtrbf
        st point1_y

                        ;; get second point

        inc offset
        ld offset
        ldc
        add acc         ;; every point has 2 bytes
        add #192
        st vrmad1
        ld vtrbf
        st point2_x
        ld vtrbf
        st point2_y

        callf clip_and_draw_lines

;        callf draw_line
        mov #0, vrmad2          ; refresh for softvms

        dbnz nlines, .nextline

        brf .end

.polylines:

        ;; it's a collection of polylines

                ;; get number of polylines

        ld offset
        ldc
        inc offset
        st npolylines

.nextpolyline:
                        ;; get number of line segments

        ld offset
        ldc
        inc offset
        st nlines

                        ;; get first point

        ld offset
        ldc
        inc offset
        add acc         ;; every point has 2 bytes
        add #192
        st vrmad1
        ld vtrbf
        st point2_x
        ld vtrbf
        st point2_y

        clr1 control, fast_polyline

.nextlinesegment:

                                ;; copy over old point

        ld point2_x
        st point1_x
        ld point2_y
        st point1_y

                                ;; get second point

        ld offset
        ldc
        inc offset
        add acc                 ;; every point has 2 bytes
        add #192
        st vrmad1
        ld vtrbf
        st point2_x
        ld vtrbf
        st point2_y

        callf clip_and_draw_lines

;        callf draw_line
        mov #0, vrmad2          ; refresh for softvms

;        set1 control, fast_polyline

        dbnz nlines, .nextlinesegment

        dbnz npolylines, .nextpolyline

        clr1 control, fast_polyline

.end:
        pop vrmad2
        pop vrmad1
        pop vsel
        pop 1
        pop c
        pop count
        pop acc

        ret

