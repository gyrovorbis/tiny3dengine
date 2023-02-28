                                    
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


        ;; polygon data for testing

;; a cube made of lines
polygon_data_05:
        .byte 2          ;; data type: lines
        .byte 8          ;; number of points

                ;; frontplane

        .byte $00        ;; x   top right
        .byte $05
        .byte $FF        ;; y
        .byte $FB
        .byte $FF        ;; z
        .byte $FB

        .byte $00        ;; x   bottom right
        .byte $05
        .byte $00        ;; y
        .byte $05
        .byte $FF        ;; z
        .byte $FB

        .byte $FF        ;; x   bottom left
        .byte $FB
        .byte $00        ;; y
        .byte $05
        .byte $FF        ;; z
        .byte $FB

        .byte $FF        ;; x   top left
        .byte $FB
        .byte $FF        ;; y
        .byte $FB
        .byte $FF        ;; z
        .byte $FB

                ;; backplane

        .byte $00        ;; x   top right           
        .byte $05
        .byte $FF        ;; y
        .byte $FB
        .byte $00        ;; z
        .byte $05

        .byte $00        ;; x   bottom right
        .byte $05
        .byte $00        ;; y
        .byte $05
        .byte $00        ;; z
        .byte $05

        .byte $FF        ;; x   bottom left
        .byte $FB
        .byte $00        ;; y
        .byte $05
        .byte $00        ;; z
        .byte $05

        .byte $FF        ;; x   top left
        .byte $FB
        .byte $FF        ;; y
        .byte $FB
        .byte $00        ;; z
        .byte $05

        .byte 12         ;; number of lines

        ;; front plane

        .byte 0,1
        .byte 1,2
        .byte 2,3
        .byte 3,0

        ;; back plane

        .byte 4,5
        .byte 5,6
        .byte 6,7
        .byte 7,4

        ;; connection lines

        .byte 0,4
        .byte 1,5
        .byte 2,6
        .byte 3,7

;; a cube made of polylines
polygon_data_04:
        .byte 3          ;; data type: polylines
        .byte 8          ;; number of points

                ;; frontplane

        .byte $00        ;; x   top right
        .byte $05
        .byte $FF        ;; y
        .byte $FB
        .byte $FF        ;; z
        .byte $FB

        .byte $00        ;; x   bottom right
        .byte $05
        .byte $00        ;; y
        .byte $05
        .byte $FF        ;; z
        .byte $FB

        .byte $FF        ;; x   bottom left
        .byte $FB
        .byte $00        ;; y
        .byte $05
        .byte $FF        ;; z
        .byte $FB

        .byte $FF        ;; x   top left
        .byte $FB
        .byte $FF        ;; y
        .byte $FB
        .byte $FF        ;; z
        .byte $FB

                ;; backplane

        .byte $00        ;; x   top right           
        .byte $05
        .byte $FF        ;; y
        .byte $FB
        .byte $00        ;; z
        .byte $05

        .byte $00        ;; x   bottom right
        .byte $05
        .byte $00        ;; y
        .byte $05
        .byte $00        ;; z
        .byte $05

        .byte $FF        ;; x   bottom left
        .byte $FB
        .byte $00        ;; y
        .byte $05
        .byte $00        ;; z
        .byte $05

        .byte $FF        ;; x   top left
        .byte $FB
        .byte $FF        ;; y
        .byte $FB
        .byte $00        ;; z
        .byte $05

        .byte 4         ;; number of polylines

        ;; longest polyline

        .byte 9                         ;; number of line segments

        .byte 0,1,2,3,0,4,5,6,7,4       ;; point indices between which are the line segments

        ;; 1st line segment

        .byte 1

        .byte 3,7

        ;; 2nd line segment

        .byte 1

        .byte 2,6

        ;; 3rd line segment

        .byte 1

        .byte 1,5


;; a pyramid made of points
polygon_data_03:
        .byte 0          ;; data type: points
        .byte 5          ;; number of points

        .byte $00        ;; x   top
        .byte $00
        .byte $FF        ;; y
        .byte $FB
        .byte $00        ;; z
        .byte $00

        .byte $FF        ;; x   front left
        .byte $FB
        .byte $00        ;; y
        .byte $05
        .byte $FF        ;; z
        .byte $FB

        .byte $00        ;; x   front right
        .byte $05
        .byte $00        ;; y
        .byte $05
        .byte $FF        ;; z
        .byte $FB

        .byte $00        ;; x   back right
        .byte $05
        .byte $00        ;; y
        .byte $05
        .byte $00        ;; z
        .byte $05

        .byte $FF        ;; x   back left
        .byte $FB
        .byte $00        ;; y
        .byte $05
        .byte $00        ;; z
        .byte $05

;; a pyramid made of polylines
polygon_data_02:
        .byte 3          ;; data type: polylines
        .byte 5          ;; number of points

        .byte $00        ;; x   top
        .byte $00
        .byte $FF        ;; y
        .byte $FB
        .byte $00        ;; z
        .byte $00

        .byte $FF        ;; x   front left
        .byte $FB
        .byte $00        ;; y
        .byte $05
        .byte $FF        ;; z
        .byte $FB

        .byte $00        ;; x   front right
        .byte $05
        .byte $00        ;; y
        .byte $05
        .byte $FF        ;; z
        .byte $FB

        .byte $00        ;; x   back right
        .byte $05
        .byte $00        ;; y
        .byte $05
        .byte $00        ;; z
        .byte $05

        .byte $FF        ;; x   back left
        .byte $FB
        .byte $00        ;; y
        .byte $05
        .byte $00        ;; z
        .byte $05

        .byte 2         ;; number of polylines

        ;; longest polyline

        .byte 7

        .byte 1,4,0,1,2,0,3,4

        ;; remaining line

        .byte 1

        .byte 2,3

;; a pyramid made of lines
polygon_data_06:
        .byte 2          ;; data type: lines
        .byte 5          ;; number of points

        .byte $00        ;; x   top
        .byte $00
        .byte $FF        ;; y
        .byte $FB
        .byte $00        ;; z
        .byte $00

        .byte $FF        ;; x   front left
        .byte $FB
        .byte $00        ;; y
        .byte $05
        .byte $FF        ;; z
        .byte $FB

        .byte $00        ;; x   front right
        .byte $05
        .byte $00        ;; y
        .byte $05
        .byte $FF        ;; z
        .byte $FB

        .byte $00        ;; x   back right
        .byte $05
        .byte $00        ;; y
        .byte $05
        .byte $00        ;; z
        .byte $05

        .byte $FF        ;; x   back left
        .byte $FB
        .byte $00        ;; y
        .byte $05
        .byte $00        ;; z
        .byte $05

        .byte 1         ;; number of lines

        ;; bottom plane

        .byte 1,2
        .byte 2,3
        .byte 3,4
        .byte 4,1

        ;; side

        .byte 0,1
        .byte 0,2
        .byte 0,3
        .byte 0,4
;; a cube made of points with center in (0,0,0)
polygon_data_01:
        .byte 0          ;; data type: points
        .byte 8          ;; number of points

                ;; frontplane

        .byte $00        ;; x   top right
        .byte $05
        .byte $FF        ;; y
        .byte $FB
        .byte $FF        ;; z
        .byte $FB

        .byte $00        ;; x   bottom right
        .byte $05
        .byte $00        ;; y
        .byte $05
        .byte $FF        ;; z
        .byte $FB

        .byte $FF        ;; x   bottom left
        .byte $FB
        .byte $00        ;; y
        .byte $05
        .byte $FF        ;; z
        .byte $FB

        .byte $FF        ;; x   top left
        .byte $FB
        .byte $FF        ;; y
        .byte $FB
        .byte $FF        ;; z
        .byte $FB

                ;; backplane

        .byte $00        ;; x   top right           
        .byte $05
        .byte $FF        ;; y
        .byte $FB
        .byte $00        ;; z
        .byte $05

        .byte $00        ;; x   bottom right
        .byte $05
        .byte $00        ;; y
        .byte $05
        .byte $00        ;; z
        .byte $05

        .byte $FF        ;; x   bottom left
        .byte $FB
        .byte $00        ;; y
        .byte $05
        .byte $00        ;; z
        .byte $05

        .byte $FF        ;; x   top left
        .byte $FB
        .byte $FF        ;; y
        .byte $FB
        .byte $00        ;; z
        .byte $05



polygon_lines_01:
        .byte 1          ;; data type: polyline
        .byte 2          ;; number of points

        .byte 0          ;; x
        .byte 19
        .byte 0          ;; y
        .byte 11
        .byte 0          ;; z
        .byte 5

        .byte 0          ;; x
        .byte 29
        .byte 0          ;; y
        .byte 11
        .byte 0          ;; z
        .byte 5

