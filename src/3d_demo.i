                                    
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


;; now here the demo

demo:
        ;; activate RC clock 600/6 = 100 kHz
        clr1 ocr, mainclk       ; disable MAIN clock
        set1 ocr, mainctl       ; stop MAIN clock
        set1 ocr, halfclk       ; set frequency divisor to 6
        clr1 ocr, rcctl         ; start RC oscillator
        clr1 ocr, subclk        ; enable RC clock

        ;; init variables
        xor acc
        st tx_high
        st tx_low
        st ty_high
        st ty_low
        st tz_high
        st tz_low

;        st s_x_low
;        st s_y_low
;        st s_z_low

        st ax_high
        st ax_low
        st ay_high
        st ay_low
        st az_high
        st az_low

        st mode_render
        inc acc         ;; edit_none
        st mode_edit
;        st s_x_high
;        st s_y_high
;        st s_z_high

        mov #>polygon_data_02, trh
        mov #<polygon_data_02, trl

        callf init_stack


        ;; above function call overwrites this

        xor acc
        st tx_high
        st tx_low
        st ty_high
        st ty_low
        st tz_high
        st tz_low

.loop:
        ;; 1. process rendering engine

        bn mode_render, do_s, .skip_s
        callf scale

.skip_s:
        bn mode_render, do_rx, .skip_rx
        callf rotate_x

.skip_rx:
        bn mode_render, do_ry, .skip_ry
        callf rotate_y

.skip_ry:
        bn mode_render, do_rz, .skip_rz
        callf rotate_z

.skip_rz:
        bn mode_render, do_t, .skip_t
        callf translate

.skip_t:

        ;; put the object behind the projection surface
        ;; check projection if this is neccessary!

;        push t_x_high
;        push t_x_low
;        push t_y_high
;        push t_y_low
;        push t_z_high
;        push t_z_low

;        xor acc
;        st t_x_high
;        st t_x_low
;        st t_y_high
;        st t_y_low
;        st t_z_high
;        mov #20, t_z_low

;        callf translate

;        pop t_z_low
;        pop t_z_high
;        pop t_y_low
;        pop t_y_high
;        pop t_x_low
;        pop t_x_high

        callf clear_framebuffer

        callf put_polygon

        callf draw_mode

        callf display_framebuffer

        ;; 2. process inputs

;;;
;        ld point1_x
;        st b
;        ld point1_y
;        st c

;; debug displays
        ;; now look at the current matrix
        ld 0
        st 1

        ;; display the last temporary matrix
;        mov #rz_start, 1
;        mov #0, xbnk
;        callf display_matrix

;        mov #c1_start, 1
;        mov #1, xbnk
;        callf display_matrix

        ld 0
        st b
;        mov #c0_start, c

        ;; display the last transformed vector
;        mov #temp_vector, 1
;        callf display_vector

.waitrelease:
        callf getkeys
        bn acc, pressed_a, .waitrelease
        bn acc, pressed_b, .waitrelease

.wait:
        callf getkeys
        be #$FF, .wait

        callf get_inputs

        ;; prepare for next loop iteration
        callf reset_stack

        br .loop


        ret


draw_mode:
        push count
        push offset
        push vrmad1
        push vrmad2
        push vsel
        push trl
        push trh

        ;; 1. select mode_pix offset

        mov #0, offset
        ld mode_edit

.next_pic:
        bp acc, 7, .this_pic
        rol
        inc offset
        br .next_pic

.this_pic:
                ;; offset now holds the number of the pic,
                ;; now compute real offset

        ld offset
        st c
        mov #12, b
        xor acc

        mul

        ld c    ;; the offset
        st offset

        ;; 2. draw pic in framebuffer

        mov #<mode_pix, trl
        mov #>mode_pix, trh
        mov #160, vrmad1
        mov #0, vrmad2
        set1 vsel, ince
        mov #6, count

.next_line:
        ld offset
        ldc
        bn mode_render, active, .inactive1
        xor #$FF

.inactive1:
        st vtrbf
        inc offset
        ld offset
        ldc
        bn mode_render, active, .inactive2
        xor #$FF

.inactive2:
        st vtrbf
        inc offset
        ld vrmad1
        add #4
        st vrmad1

        dbnz count, .next_line

        pop trh
        pop trl
        pop vsel
        pop vrmad2
        pop vrmad1
        pop offset
        pop count


        ret




get_inputs:
        push acc
        push 1
        push c
        push A_high
        push A_low
        push B_high
        push B_low

        ;; act acording to edit mode

        st c

        ;; priority to changing editing mode
        bp c, pressed_a, .skip_up_edit
        ld mode_edit
        rol
        st mode_edit
;        ret
        ;; proceed with mode evaluation to determine if transform is active
        mov #$FF, c

.skip_up_edit:
;        bp c, pressed_b, .skip_down_edit
;        ror
;        st mode_edit
;        ret
;
;.skip_down_edit:

        ;; if no mode change...

        clr1 mode_render, active

        bn mode_edit, edit_txy, .skip_txy
        bp c, pressed_b, .skip_b_txy
        not1 mode_render, do_t

.skip_b_txy:
        bp c, pressed_left, .skip_left_txy
        mov #tx_low, 1
        callf dec_16bit

.skip_left_txy:
        bp c, pressed_right, .skip_right_txy
        mov #tx_low, 1
        callf inc_16bit

.skip_right_txy:
        bp c, pressed_up, .skip_up_txy
        mov #ty_low, 1
        callf dec_16bit

.skip_up_txy:
        bp c, pressed_down, .skip_down_txy
        mov #ty_low, 1
        callf inc_16bit

.skip_down_txy:
        bn mode_render, do_t, .inactive_txy
        set1 mode_render, active

.inactive_txy:
        jmp .end

.skip_txy:


        bn mode_edit, edit_txz, .skip_txz
        bp c, pressed_b, .skip_b_txz
        not1 mode_render, do_t

.skip_b_txz:
        bp c, pressed_left, .skip_left_txz
        mov #tx_low, 1
        callf dec_16bit

.skip_left_txz:
        bp c, pressed_right, .skip_right_txz
        mov #tx_low, 1
        callf inc_16bit

.skip_right_txz:
        bp c, pressed_up, .skip_up_txz
        mov #tz_low, 1
        callf inc_16bit

.skip_up_txz:
        bp c, pressed_down, .skip_down_txz
        mov #tz_low, 1
        callf dec_16bit 

.skip_down_txz:
        bn mode_render, do_t, .inactive_txz
        set1 mode_render, active

.inactive_txz:
        jmp .end

.skip_txz:


        bn mode_edit, edit_rxy, .skip_rxy

        mov #$00, B_high
        mov #$09, B_low

        bp c, pressed_b, .skip_b_rxy
        not1 mode_render, do_ry
;        clr1 mode_render, do_rx
;        bn mode_render, do_ry, .reset_rxy
;        set1 mode_render, do_rx
        bp mode_render, do_rz, .reset_rxy       ; only change do_rx when rxz is inactive
        not1 mode_render, do_rx

.reset_rxy:

.skip_b_rxy:
        ld ay_high
        st A_high
        ld ay_low
        st A_low

        bp c, pressed_left, .skip_left_rxy
        callf add_16bit

.skip_left_rxy:
        bp c, pressed_right, .skip_right_rxy
        callf sub_16bit

.skip_right_rxy:
        ld A_high
        st ay_high
        ld A_low
        st ay_low

        ld ax_high
        st A_high
        ld ax_low
        st A_low

        bp c, pressed_up, .skip_up_rxy
        callf sub_16bit

.skip_up_rxy:
        bp c, pressed_down, .skip_down_rxy
        callf add_16bit

.skip_down_rxy:
        ld A_high
        st ax_high
        ld A_low
        st ax_low

        bn mode_render, do_rx, .inactive_rxy
        bn mode_render, do_ry, .inactive_rxy
        set1 mode_render, active

.inactive_rxy:
        jmp .end

.skip_rxy:


        bn mode_edit, edit_rxz, .skip_rxz

        mov #$00, B_high
        mov #$09, B_low

        bp c, pressed_b, .skip_b_rxz
        not1 mode_render, do_rz
;        clr1 mode_render, do_rx
;        bn mode_render, do_rz, .reset_rxz
;        set1 mode_render, do_rx
        bp mode_render, do_ry, .reset_rxz       ; only change do_rx when rxy is inactive
        not1 mode_render, do_rx

.reset_rxz:

.skip_b_rxz:
        ld az_high
        st A_high
        ld az_low
        st A_low

        bp c, pressed_left, .skip_left_rxz
        callf sub_16bit

.skip_left_rxz:
        bp c, pressed_right, .skip_right_rxz
        callf add_16bit

.skip_right_rxz:
        ld A_high
        st az_high
        ld A_low
        st az_low

        ld ax_high
        st A_high
        ld ax_low
        st A_low

        bp c, pressed_up, .skip_up_rxz
        callf sub_16bit

.skip_up_rxz:
        bp c, pressed_down, .skip_down_rxz
        callf add_16bit

.skip_down_rxz:
        ld A_high
        st ax_high
        ld A_low
        st ax_low

        bn mode_render, do_rx, .inactive_rxz
        bn mode_render, do_rz, .inactive_rxz
        set1 mode_render, active

.inactive_rxz:
        jmp .end

.skip_rxz:


        bn mode_edit, edit_sxy, .skip_sxy

        mov #$00, B_high
        mov #$20, B_low

        bp c, pressed_b, .skip_b_sxy
        not1 mode_render, do_s

.skip_b_sxy:
        ld sx_high
        st A_high
        ld sx_low
        st A_low

        bp c, pressed_left, .skip_left_sxy
        callf sub_16bit

.skip_left_sxy:
        bp c, pressed_right, .skip_right_sxy
        callf add_16bit

.skip_right_sxy:
        ld A_high
        st sx_high
        ld A_low
        st sx_low

        ld sy_high
        st A_high
        ld sy_low
        st A_low

        bp c, pressed_up, .skip_up_sxy
        callf add_16bit

.skip_up_sxy:
        bp c, pressed_down, .skip_down_sxy
        callf sub_16bit

.skip_down_sxy:
        ld A_high
        st sy_high
        ld A_low
        st sy_low

        bn mode_render, do_s, .inactive_sxy
        set1 mode_render, active

.inactive_sxy:
        jmp .end

.skip_sxy:


        bn mode_edit, edit_sxz, .skip_sxz

        mov #$00, B_high
        mov #$20, B_low

        bp c, pressed_b, .skip_b_sxz
        not1 mode_render, do_s

.skip_b_sxz:
        ld sx_high
        st A_high
        ld sx_low
        st A_low

        bp c, pressed_left, .skip_left_sxz
        callf sub_16bit

.skip_left_sxz:
        bp c, pressed_right, .skip_right_sxz
        callf add_16bit

.skip_right_sxz:
        ld A_high
        st sx_high
        ld A_low
        st sx_low

        ld sz_high
        st A_high
        ld sz_low
        st A_low

        bp c, pressed_up, .skip_up_sxz
        callf add_16bit

.skip_up_sxz:
        bp c, pressed_down, .skip_down_sxz
        callf sub_16bit

.skip_down_sxz:
        ld A_high
        st sz_high
        ld A_low
        st sz_low

        bn mode_render, do_s, .inactive_sxz
        set1 mode_render, active

.inactive_sxz:
        jmp .end

.skip_sxz:


        bn mode_edit, edit_freq, .skip_freq
        bp c, pressed_left, .skip_left_freq
        ;; activate RC clock 600/12 = 50 kHz
        clr1 ocr, mainclk       ; disable MAIN clock
        set1 ocr, mainctl       ; stop MAIN clock
        clr1 ocr, halfclk       ; set frequency divisor to 12
        clr1 ocr, rcctl         ; start RC oscillator
        clr1 ocr, subclk        ; enable RC clock

.skip_left_freq:
        bp c, pressed_right, .skip_right_freq
        ;; activate RC clock 600/12 = 50 kHz
        clr1 ocr, mainclk       ; disable MAIN clock
        set1 ocr, mainctl       ; stop MAIN clock
        clr1 ocr, halfclk       ; set frequency divisor to 12
        clr1 ocr, rcctl         ; start RC oscillator
        clr1 ocr, subclk        ; enable RC clock

.skip_right_freq:
        bp c, pressed_up, .skip_up_freq
        ;; activate RC clock 600/6 = 100 kHz
        clr1 ocr, mainclk       ; disable MAIN clock
        set1 ocr, mainctl       ; stop MAIN clock
        set1 ocr, halfclk       ; set frequency divisor to 6
        clr1 ocr, rcctl         ; start RC oscillator
        clr1 ocr, subclk        ; enable RC clock

; deactivated
        ;; set MAIN clock
;        clr1 ocr, rcctl         ; start RC oscillator
;        clr1 ocr, subclk        ; enable RC clock
;        clr1 ocr, mainctl       ; start MAIN clock
;        set1 ocr, mainclk       ; enable MAIN clock
;        set1 ocr, rcctl         ; stop RC clock

.skip_up_freq:
        bp c, pressed_down, .skip_down_freq
        ;; set SUB clock
        clr1 ocr, mainclk       ; disable MAIN clock
        set1 ocr, mainctl       ; stop MAIN clock
        set1 ocr, subclk        ; enable SUB clock
        set1 ocr, rcctl         ; stop RC oscillator

.skip_down_freq:
        jmp .end

.skip_freq:


        bn mode_edit, edit_data, .skip_data

        bp c, pressed_b, .skip_b_data
        not1 control, no_clipping

.skip_b_data:
        bp c, pressed_left, .skip_left_data
        mov #>polygon_data_03, trh
        mov #<polygon_data_03, trl

.skip_left_data:
        bp c, pressed_right, .skip_right_data
        mov #>polygon_data_01, trh
        mov #<polygon_data_01, trl

.skip_right_data:
        bp c, pressed_up, .skip_up_data
        mov #>polygon_data_04, trh
        mov #<polygon_data_04, trl

.skip_up_data:
        bp c, pressed_down, .skip_down_data
        mov #>polygon_data_02, trh
        mov #<polygon_data_02, trl

.skip_down_data:
        bn control, no_clipping, .inactive_data
        set1 mode_render, active

.inactive_data:

.skip_data:

.end:
        pop B_low
        pop B_high
        pop A_low
        pop A_high
        pop c
        pop 1
        pop acc

        ret

