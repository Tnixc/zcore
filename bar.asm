set r0, 1    ; r0 = counter (starts at 1)
set r1, 6    ; r1 = limit (count up to 5, but use 6 for comparison)
set r2, 0    ; r2 = sum
set r3, 1    ; r3 = increment value
set r4, 100  ; r4 = base memory address for storing results

; Store initial counter value in memory
store r0, r4

halt_program:
    ; End program
    halt

end_loop:
    ; Output final sum
    out r2

    ; Load and output all stored sums
    set r7, 1  ; Initialize loop counter for outputting stored sums

; Main loop
loop:
    ; Output current number
    out r0

    ; Add current number to sum
    add r2, r2, r0

    ; Store current sum in memory
    add r5, r4, r0  ; Calculate memory address (base + offset)
    store r2, r5    ; Store sum at calculated address

    ; Increment counter
    add r0, r0, r3

    ; Compare counter with limit
    sub r6, r1, r0
    jumpz end_loop

    ; Continue loop
    jump loop

output_loop:
    add r5, r4, r7  ; Calculate memory address
    load r6, r5     ; Load stored sum from memory
    out r6          ; Output loaded sum

    add r7, r7, r3  ; Increment loop counter
    sub r6, r1, r7  ; Compare with limit
    jumpz halt_program
    jump output_loop

