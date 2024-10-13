end:
    halt ; 3
    loadi R0, 128 ; 4
    jump end ; 5

somelabel:
    loadi R0, 128 ; 6
    jump somelabel ; 7

; Main loop
loop:
    ; Print current number ()
    out [R0] ; 8

    ; Increment counter
    load R2, 1 ; 9
    add R0, R0, R2 ; 10

    ; Compare counter with end condition
    sub R3, R0, R1 ; 11

    ; If counter <= 5, continue loop
    jumpz loop ; 12

