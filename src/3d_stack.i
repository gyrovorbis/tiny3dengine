                                    
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


        ;; function     "push_matrix"
        ;;              - copies the currrent matrix on stack 
        ;;                and increments stack_entries and adjusts stack_top
        ;; INPUTS:      - stack_top
        ;; OUTPUTS:     - stack_top
        ;;              - stack_entries

push_matrix:
        push acc
        push count
        push vrmad1
        push vrmad2
        push vsel
        

        ;; copy the current matrix on top of matrix stack

                ;; prepare
        
        ld stack_top
        st vrmad1
        mov #1, vrmad2
        set1 vsel, ince

        mov #24, count

                ;; copy loop

.next_byte:            
        ld @R0
        st vtrbf
        inc 0

        dbnz count, .next_byte

        ;; now adjust the matrix pointer and the number of matrices in stack
        ld vrmad1
        st stack_top
        inc stack_entries

        ;; reset current matrix pointer(faster than push/pop)

        ld 0
        sub #24
        st 0

        pop vsel
        pop vrmad2
        pop vrmad1
        pop count
        pop acc

        ret




push_unit_matrix:
        callf push_matrix
        set1 control, first_mm

        ret





        ;; function:    "pop_matrix"
        ;;              - if there is at least one matrix in the stack,
        ;;                it decrements the matrix pointer
        ;; INPUTS:      - stack_elements
        ;; OUTPUTS:     - stack_elements
        ;;              - stack_top

pop_matrix:
        push acc
        push count
        push vrmad1
        push vrmad2
        push vsel

        ;; only pop matrix, when there is at least one in the stack
        ld stack_entries
        bz .end

        ;; copy the top of matrix stack to current matrix

                ;; prepare
        
        ld stack_top
        sub #24
        st stack_top
        st vrmad1
        mov #1, vrmad2
        set1 vsel, ince

        mov #24, count

                ;; copy loop, reverse order

.next_byte:            
        ld vtrbf
        st @R0
        inc 0

        dbnz count, .next_byte

        ;; now adjust the number of matrices in stack

        dec stack_entries

        ;; reset current matrix pointer(faster than push/pop)

        ld 0
        sub #24
        st 0

.end:
        pop vsel
        pop vrmad2
        pop vrmad1
        pop count
        pop acc

        ret



        ;; function:    "init_stack"
        ;;              - sets transformation and current matrix skeletons, settings and pointers


init_stack:
        push acc
        push trl
        push trh
        push offset
        push count

        ;; now copy over the matrix skeletons

                ;; prepare

        mov #t_start, 0

        mov #<matrix_skeletons, trl
        mov #>matrix_skeletons, trh

        mov #168, count
        mov #0, offset

                ;; copy loop

.next_byte:
        ld offset
        ldc
        st @R0
        inc 0
        inc offset

        dbnz count, .next_byte

        mov #0, stack_entries           ; for sure
        mov #stack_top, 0

        set1 control, first_mm
        clr1 control, current_matrix    ; set current matrix location
        mov #c0_start, 0

        pop count
        pop offset
        pop trh
        pop trl
        pop acc

        ret


        ;; function:    "reset_stack"
        ;;              - makes current matrix a unit matrix and clears the stack


reset_stack:
        push acc
        push count

        ;; make the current matrices a unit matrix

                ;; first clear them

        mov #c1_start, 0
        mov #48, count
        xor acc

.next_byte:
        st @R0
        inc 0

        dbnz count, .next_byte

                ;; then insert the 1's

        mov #1, acc
        st 252
        st 242
        st 232

        st 228
        st 218
        st 208

        ;; make stack empty

        mov #0, stack_entries           ; for sure
        mov #stack_top, 0

        set1 control, first_mm
        clr1 control, current_matrix    ; set current matrix location
        mov #c0_start, 0

        pop count
        pop acc

        ret

