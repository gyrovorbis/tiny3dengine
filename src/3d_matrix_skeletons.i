                                    
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


matrix_skeletons:


;; RAM 88:

        ;; translation
        ;;             / 1 0 0 tx \
        ;;             | 0 1 0 ty |
        ;;             | 0 0 1 tz |
        ;;             \ 0 0 0 1  /

        .byte   1,0, 0,0, 0,0, 0,0
        .byte   0,0, 1,0, 0,0, 0,0
        .byte   0,0, 0,0, 1,0, 0,0

; just a test matrix...
;        .byte   1,2, 3,4, 5,6, 7,8
;        .byte   9,10, 11,12, 13,14, 15,16
;        .byte   17,18, 19,20, 21,22, 23,24

;; RAM 112:

        ;; scaling
        ;;             / sx 0  0  0 \
        ;;             | 0  sy 0  0 |
        ;;             | 0  0  sz 0 |
        ;;             \ 0  0  0  1 /

        .byte   1,0, 0,0, 0,0, 0,0
        .byte   0,0, 1,0, 0,0, 0,0
        .byte   0,0, 0,0, 1,0, 0,0

;; RAM 136:

        ;; x-axis rotation
        ;;             / 1 0          0           0 \
        ;;             | 0 cos(angle) -sin(angle) 0 |
        ;;             | 0 sin(angle) cos(angle)  0 |
        ;;             \ 0 0          0           1 /

        .byte   1,0, 0,0, 0,0, 0,0
        .byte   0,0, 0,0, 0,0, 0,0
        .byte   0,0, 0,0, 0,0, 0,0

;; RAM 160:

        ;; y-axis rotation
        ;;             / cos(angle)  0 sin(angle) 0 \
        ;;             | 0           1 0          0 |
        ;;             | -sin(angle) 0 cos(angle) 0 |
        ;;             \ 0           0 0          1 /

        .byte   0,0, 0,0, 0,0, 0,0
        .byte   0,0, 1,0, 0,0, 0,0
        .byte   0,0, 0,0, 0,0, 0,0

;; RAM 184:

        ;; z-axis rotation
        ;;             / cos(angle) -sin(angle) 0 0 \
        ;;             | sin(angle) cos(angle)  0 0 |
        ;;             | 0          0           1 0 |
        ;;             \ 0          0           0 1 /

        .byte   0,0, 0,0, 0,0, 0,0
        .byte   0,0, 0,0, 0,0, 0,0
        .byte   0,0, 0,0, 1,0, 0,0

;; RAM 208:

        ;; current matrix 0
        ;;             / 1 0 0 tx \
        ;;             | 0 1 0 ty |
        ;;             | 0 0 1 tz |
        ;;             \ 0 0 0 1  /

        .byte   1,0, 0,0, 0,0, 0,0
        .byte   0,0, 1,0, 0,0, 0,0
        .byte   0,0, 0,0, 1,0, 0,0

;; RAM 232:

        ;; current matrix 1
        ;;             / 1 0 0 tx \
        ;;             | 0 1 0 ty |
        ;;             | 0 0 1 tz |
        ;;             \ 0 0 0 1  /

        .byte   1,0, 0,0, 0,0, 0,0
        .byte   0,0, 1,0, 0,0, 0,0
        .byte   0,0, 0,0, 1,0, 0,0

;; RAM 256: out of range

