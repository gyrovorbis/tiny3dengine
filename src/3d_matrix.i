                                    
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


        ;; function:    "multiply_matrix"
        ;;              - multiplies the current matrix with the specified matrix
        ;;                from the left
        ;;              - result overwrites current matrix
        ;; INPUTS:      - R1 points to matrix to multiply with
        ;;              - R0 points to current matrix
        ;; OUTPUTS:     - current matrix in RAM
        ;; NEEDS:       - additional(to variable rescue on enter AND nested functions)
        ;;                32 bytes in stack for resulting temporary matrix

multiply_matrix:
        push acc
        push count
        push c
        push 1

        mov #3, count   ; 4 rows(left matrix)

        ;; prepare for 1st pointer adjustment

        ld 1
        sub #8
        st 1

        ld 0
        add #24
        st 8
        
        ;; pointer 12 points to start of result matrix
        ;; select free current matrix

        mov #c1_start, 12
        bn control, current_matrix, .next_row
        mov #c0_start, 12

.next_row:
        mov #4, c       ; 4 columns(right matrix, but transposed, so row instead of column) for each row(left matrix)
        clr1 control, full_dimension
        ;; set pointers

                ;; left matrix (R1)
                ;; adjust R1 to point to next row

        ld 1
        add #8
        st 1
        add #2
        st 5
        add #2
        st 9
        ;; pointer to 4th element of left matrix needs to be set only when multiplied with last column

                ;; right matrix (R0)
                ;; adjust R0 to point to first column

        ;; pointer to 4th row of right matrix is not necessary
        ld 8
        sub #8
        st 8
        sub #8
        st 4
        sub #8
        st 0

.next_column:
        ;; only last column needs 4 dimensions, others only 3

        ld c
        bne #1, .small_dimension
        set1 control, full_dimension

        ;; adjust last element's(of left matrix) pointer

        ld 9
        add #2
        st 13

.small_dimension:
        callf dot_product

        dbnz c, .next_column

        dbnz count, .next_row

        ;; set new current matrix

        not1 control, current_matrix

        mov #c1_start, 0
        bp control, current_matrix, .skip
        mov #c0_start, 0

.skip:
        pop 1
        pop c
        pop count
        pop acc

        ret




        ;; function     "copy_matrix"
        ;;              - copies source 3x4 matrix to destination 3x4 part of 4x4 matrix
        ;; INPUTS:      - R1 points to source matrix start
        ;;              - R0 points to target matrix start

copy_matrix:
        push acc
        push 0
        push 1
        push count

        mov #24, count

.loop:
        ld @R1
        st @R0
        inc 1
        inc 0

        dbnz count, .loop


        pop count
        pop 1
        pop 0
        pop acc

        ret



        ;; function: "display_matrix"
        ;;      for debugging: prints the specified matrix with this format:
        ;;
        ;;      11 12
        ;;
        ;;      21 22
        ;;
        ;;      31 32
        ;;
        ;;      41 42
        ;;
        ;;      13 14
        ;;
        ;;      23 24
        ;;
        ;;      33 34
        ;;
        ;;      43 44
        ;;
        ;; INPUTS:      - R1 points to element 11 of matrix to display
        ;;              - xbnk selects upper or lower half of screen


display_matrix:
;        push xbnk
        push 2
        push c
        push count

;        mov #0, xbnk
        mov #$80, 2


        ;; process elements 1x and 2x
        mov #3, c

.loop:
        callf display_2_elements

        ld 2
        add #6
        st 2
        ld 1
        add #4
        st 1

        dbnz c, .loop


        ;; adjust to element 13 of matrix
        ld 1
        sub #20
        st 1

        ;; process elements 3x and 4x
        mov #3, c

.loop1:
        callf display_2_elements

        ld 2
        add #6
        st 2
        ld 1
        add #4
        st 1

        dbnz c, .loop1


        pop count
        pop c
        pop 2
;        pop xbnk

        ret



display_2_elements:
        mov #4, count

.loop:
        ld @R1
        st @R2
        inc 1
        inc 2

        dbnz count, .loop


        inc 2
        inc 2

        ;; underline

        mov #4, count

.loop1:
        mov #$FF, @R2
        inc 2

        dbnz count, .loop1

        ret

