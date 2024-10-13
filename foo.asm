; Initialize registers
loadi r0, 1    ; r0 = counter (starts at 1)
loadi r1, 6    ; r1 = limit (count up to 5)
loadi r2, 0    ; r2 = sum

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
    loadi r3, 1
    add r0, r0, r3

    ; Compare counter with limit
    sub r3, r1, r0
    jumpz end_loop

    ; Continue loop
    jump loop

