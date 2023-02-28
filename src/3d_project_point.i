                                    
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


project_point:
        mov #temp_vector, acc
        add #4
        st 1
                        ;; x axis first(first component in workRAM)
                        ;; Sx = (Sz - Cz)*dx/dz - Cx
                        ;;    = (0 - Cz)*(Px - 0)/(Pz - Cz) + 0
                        ;;    = (-Cz * Px)/(Pz - Cz)


                                ;; (Pz - Cz)

        ld @R1
        st A_high
        inc 1
        ld @R1
        st A_low
        mov #Cz_high, B_high
        mov #Cz_low, B_low

        callf sub_16bit

        push A_high
        push A_low
                                ;; (0 - Cz)

        mov #0, A_high
        mov #0, A_low

        callf sub_16bit

                                ;; (0 - Cz) / (Pz - Cz)

                                        ;; move (0 - Cz) to C

        ld A_high
        st C_high
        ld A_low
        st C_low

                                        ;; move (Pz - Cz) from stack to B

        pop B_low
        pop B_high

        callf div_16bit

        ;; result is in C_x, save for y projection
        push C_high
        push C_low


                                ;; (0 - Cz)/(Pz - Cz) * Px

                                        ;; move Px to B

        mov #temp_vector, 1
        ld @R1
        st B_high
        inc 1
        ld @R1
        st B_low
        inc 1

        callf mul_16bit

                                ;; select low 16 bit to proceed

        ld C_high
        st A_high
        ld C_low
        st A_low

                                ;; move right for half of screen width

        mov #0, B_high          
        mov #24, B_low
        callf add_16bit

                                ;; Sx: select low 8 bits for display

        ld A_low
        st vtrbf

                        ;; y axis second(second component in workRAM)

                        ;; Sy = (Sz - Cz)*dy/dz - Cy
                        ;;    = (0 - Cz)*(Py - 0)/(Pz - Cz) + 0
                        ;;    = (-Cz * Py)/(Pz - Cz)

                                ;; (0 - Cz)/(Pz - Cz) * (Py - Cy)

                                        ;; move Py to B

        ld @R1
        st B_high
        inc 1
        ld @R1
        st B_low

                                        ;; move (0 - Cz)/(Pz - Cz) from stack to C

        pop C_low
        pop C_high

        callf mul_16bit

                                ;; select low 16 bit to proceed

        ld C_high
        st A_high
        ld C_low
        st A_low

                                ;; move down for half of screen height

        mov #0, B_high          
        mov #16, B_low
        callf add_16bit

                                ;; Sy: select low 8 bits for display

        ld A_low
        st vtrbf

        ret

