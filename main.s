/* 345184378 Geoffrey Baum */

.extern printf
.extern scanf

.section .data # data that is subject to change
easy_answer: 
    .space 8, 0x0
double_answer:
    .space 8, 0x0
seed: 
    .space 8, 0x0
N: 
    .space 8, 0x0
random: 
    .space 8, 0x0
user_guess:
    .space 8, 0x0
win_counter: 
    .space 8, 0x0
guess_counter: 
    .space 8, 0x0

.section .rodata #read-only data
config: 
    .string "Enter configuration seed: "
easy_prompt: 
    .string "Would you like to play in easy mode? (y/n) "
guess_prompt: 
    .string "What is your guess? "
incorrect: 
    .string "Incorrect. "
double: 
    .string "Double or nothing! Would you like to continue to another round? (y/n) "
finish: 
    .string "Congratz! You won %d rounds! \n"
higher: 
    .string "Your guess was below the actual number ... \n"
lower: 
    .string "Your guess was above the actual number ... \n"
game_over:
    .string "\nGame over, you lost :(. The correct answer was %d \n"
fmt_int: 
    .string "%d"
fmt_char: 
    .asciz " %c"

.section .text
.globl main
.type main, @function
main:
    pushq %rbp
    movq %rsp, %rbp

    movq $config, %rdi # requesting from the user the configuration seed value
    xorl %eax, %eax
    call printf

    mov $fmt_int, %rdi # recieving the seed value from the user
    xor %rsi, %rsi
    mov $seed, %rsi
    xor %rax, %rax
    call scanf

    mov (N), %rcx # initilize N to 10
    add $0xA, %rcx
    mov %rcx, N

.random_generation: # generating random number 
    xor %rdi, %rdi
    movq (seed), %rdi
    call srand
    xorq %rax, %rax
    call rand

    xor %rcx, %rcx
    movq N, %rcx
    xor %rdx, %rdx
    div %rcx
    movq %rdx, random

    movq (random), %rcx # between 0 and N
    inc %rcx
    mov %rcx, random

    movb easy_answer, %al # checking if user has already entered easy mode
    cmpb $0x0, %al
    jne .game_start

.easy_mode: # promting the user with an easy mode option
    xor %rdi, %rdi
    movq $easy_prompt, %rdi
    xorl %eax, %eax
    call printf

    mov $fmt_char, %rdi
    xor %rsi, %rsi
    mov $easy_answer, %rsi
    xor %rax, %rax
    call scanf

.game_start:
    movq $0x0, (guess_counter) # sets total guesses to 0

.guessing:
    xor %rdi, %rdi
    movq $guess_prompt, %rdi
    call printf

    mov $fmt_int, %rdi #recieves the user's guess
    xor %rsi, %rsi
    mov $user_guess, %rsi
    xor %rax, %rax
    call scanf

    mov (random), %rax # comparing between the user's guess and the random value
    mov (user_guess), %rbx
    cmp %rax, %rbx

    je .correct

    xor %rdi, %rdi # prints incorrect message
    mov $incorrect, %rdi
    call printf

    mov (guess_counter), %rcx
    inc %rcx # increment guess counter
    mov %rcx, guess_counter
    xor %rdx, %rdx
    mov $0x5, %rdx # check if more than m = 5 guesses
    cmp (guess_counter), %rdx
    je .game_end

    movb easy_answer, %al # checking if a hint needs to be provided
    cmpb $'y', %al
    jne .guessing

    mov (random), %rax # calculating which hint is needed
    mov (user_guess), %rbx
    cmp %rax, %rbx
    jl .higher_num

    xor %rdi, %rdi
    mov $lower, %rdi

    jmp .print_guess

.higher_num:
    xor %rdi, %rdi
    mov $higher, %rdi

.print_guess:
    xor %eax, %eax
    call printf

    jmp .guessing

.correct:
    mov (win_counter), %rcx # incrementing the win counter
    inc %rcx
    mov %rcx, win_counter

    xor %rdi, %rdi # double down option
    movq $double, %rdi
    xorl %eax, %eax
    call printf

    mov $fmt_char, %rdi
    xor %rsi, %rsi
    mov $double_answer, %rsi
    xor %rax, %rax
    call scanf

    movb double_answer, %al
    cmpb $'y', %al
    jne .end

    mov (seed), %eax # double seed
    add %eax, %eax
    mov %eax, seed

    mov (N), %rcx # double N
    add %rcx, %rcx
    mov %rcx, N

    jmp .random_generation

.end:
    mov $finish, %rdi # prints the user's win record
    mov (win_counter), %rsi
    call printf
    jmp .done

.game_end:
    mov $game_over, %rdi # prints the random value
    mov (random), %rsi
    call printf
    jmp .done

.done: 
    movq %rbp, %rsp
    popq %rbp
    ret
