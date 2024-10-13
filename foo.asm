; Initialize counter (R0) to 1
load R0, 1

; Initialize loop end condition (R1) to 5
load R1, 5

; Main loop
loop:
    ; Print current number ()
    out [R0]

    ; Increment counter
    load R2, 1
    add R0, R0, R2

    ; Compare counter with end condition
    sub R3, R0, R1

    ; If counter <= 5, continue loop

continue:

end:
    halt
