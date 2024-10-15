; sum numbers from 1 to 5

; Initialize registers
set r0, 1    ; r0 = counter (starts at 1)
set r1, 6    ; r1 = limit (count up to 5, but use 6 for comparison)
set r2, 0    ; r2 = sum
set r3, 1    ; r3 = increment value

end_loop:
    ; Output final sum
    out r2
    ; End program
    halt

; Main loop
loop:
    ; Output current number
    out r0

    ; Add current number to sum
    add r2, r2, r0

    ; Increment counter
    add r0, r0, r3

    ; Compare counter with limit
    sub r4, r1, r0
    jumpz end_loop ; You must define labels before you use them

    ; Continue loop
    jump loop

