    .global _start

    .section .data
    buffer:      .space 10485760 // 10MB buffer
    dictionary:   .space 1400000 // 2MB dictionary
    finaltext:   .space 1000     // 1KB final text
    character:    .space 1       // 1B character            
    word:         .space 30      // 30B word space, to store the word            
    inputfile:       .asciz "in_text_assembly.txt"     // input file name
    filedata:      .space 48                // 48B file data
    outputfile:     .asciz "output.txt"     // output file name
    read_error: .asciz "Can't read file\n"  // read error message
    open_error: .asciz "Can't open file\n"  // open error message
    newline:        .asciz "\n"            // newline character

.section .bss
    statbuf: .space 100 // 100B stat buffer

.section .text

_start:

open_file:
  
    ldr r0, =inputfile   // load the address of the filename
    mov r1, #0         // read only mode
    mov r7, #5         // open system call
    swi 0              // make the system call

    mov r4, r0          // store the file descriptor to r4

    cmp r0, #0          // check if the file is opened successfully
    blt file_open_error       // if not, jump to open_fail

    // Getting the file size
    mov r0, r4     // file descriptor (address of the file)     
    ldr r1, =statbuf   // pointer to filedata
    mov r7, #108       // stat system call
    swi 0              // make the system call
    ldr r2, =statbuf   // pointer to filedata
    ldr r11, [r2, #4]  // file size in r11

readfile:

    mov r0, r4        // file descriptor (address of the file)
    ldr r1, =buffer   // buffer to store the file content
    mov r2, r11       // file size to r2 (256B)
    mov r7, #3        // read system call
    swi 0             // make the system call  

    mov r0, r4        // file descriptor (address of the file)
    mov r7, #6        // close system call  
    swi 0             // make the system call

    mov r12, r1       // store the address of the buffer to r12  

    cmp r0, #0             // check if the file is read successfully
    blt file_read_error    // if not, jump to read_fail  

    mov r4, #0            // initialize r4 to 0
    b read_word_0        // jump to read_word_0   

read_word_0:
    ldr r5, =word  // load the address of the word
    ldr r10, =dictionary // load the address of the dictionary, dictionary index (r6). 

read_first_word:
    ldrb r3, [r12], #1  // load the character from the buffer to r3, increment the buffer address by 1 to read the next character.
    
    cmp r3, #0  // check if the character is null (end of text)
    beq end_text // if yes, jump to end_text

    cmp r3, #10 // check if the character is newline
    beq end_first_word // if yes, jump to end_first_word

    strb r3, [r5, r4] // store the character to the word buffer at index r4

    add r4, r4, #1   // increment the word index by 1 and move word offset
    
    b read_first_word // jump to read_first_word

end_first_word:
    bl add_new_word  // call addword function to add the word to the dictionary
    mov r4, #0      // reset the word index to 0
    b read_word     // jump to read_word

read_word:
    ldrb r3, [r12], #1  // load the character from the buffer to r3, increment the buffer address by 1 to read the next character.

    cmp r3, #0 // check if the character is null (end of text)
    beq end_text // if yes, jump to endoftext

    cmp r3, #10 // check if the character is newline
    beq end_word // if yes, jump to endofword
    
    strb r3, [r5, r4]   // store the character to the word buffer at index r4 with offset r5
    
    add r4, r4, #1  // increment the word index by 1 and move word offset
    
    b read_word // jump to read_word (recursive)

end_word:
    bl search_word_0 // call searchword function to search the word in the dictionary

    mov r4, #0 // reset the word index to 0

    b read_word // jump to read_word (continue text buffer reading)

end_text:
    bl search_word_0 // call searchword function to search the word in the dictionary

    ldr r0, =dictionary // load the address of the dictionary
    ldr r2, =finaltext // load the address of the finaltext
    mov r3, #0         // initialize counter for top 10 words in the dictionary in r3
    b create_text

create_text: // create the word and frequency text for the postprocessing to be read by histogram.py
    cmp r0, r10 // check if it is the end of the dictionary
    beq create_output_file // if yes, jump to create_output_file

    cmp r3, #10 // check if the top 10 words are already found
    beq create_output_file // if yes, jump to create_output_file

    ldr r8, [r0]   // obtain initial address of the word
    ldr r5, [r0, #4]  // obtain number of characters in the word
    mov r7, #0         // initialize counter for the word index in r7
    bl write_text // call write_text function to write the word to the finaltext buffer

    mov r11, #32 // load the ASCII value of space to r11
    strb r11, [r2], #1 // store the space to the finaltext buffer at index r2
    
    ldr r11, [r0, #8] // obtain the frequency of the word
    //add r11, #0 @#32      // convert the frequency to ASCII value      
    str r11, [r2], #1 // store the frequency to the finaltext buffer 
    
    mov r11, #10  // load the ASCII value of newline to r11
    str r11, [r2], #1 // store the newline to the finaltext buffer
    
    add r0, r0, #16 // increment the dictionary index by 16 to move to the next word
    add r3, r3, #1  // increment the counter for top 10 words by 1
    b create_text // jump to create_text (recursive)

create_output_file:
    ldr r0, =outputfile   // load the address of the output file name
    mov r1, #0101         // read and write mode
    mov r2, #0644         // file permission to write
    mov r7, #5            // open system call
    swi 0                 // make the system call

    mov r4, r0            // store the file descriptor to r4

    cmp r0, #0           // check if the file is opened successfully
    blt file_open_error  // if not, jump to open_fail         
    
    mov r0, r4            // move the file descriptor to r0
    ldr r1, =finaltext   // load the address of the finaltext 
    mov r2, #1000        // file size to write
    mov r7, #4            // write system call
    swi 0                 // make the system call
    
    mov r0, r4            // move the file descriptor to r0
    mov r7, #7            // exit system call (close)
    swi 0                 // make the system call

    b end                 // jump to end

write_text:
    cmp r5, r7 // check if it is the end of the word
    beq write_text_final // if yes, jump to write_text_final

    add r7, r7, #1 // increment the word index by 1

    ldr r9, [r8], #1  // load character in r8 and increment by 1.
    strb r9, [r2], #1 // store the character to the finaltext buffer at index r2 and increment by 1
    
    b write_text    // jump to write_text (recursive)

write_text_final:
    bx lr // return (end of function)

search_word_0:
    ldr r6, =dictionary    // load the initial address of the dictionary 
    
search_word:
    cmp r6, r10 // check if it is the end of the dictionary, if there are no matches then add the word to the dictionary
    beq add_new_word // if yes, jump to add_new_word
    
    ldr r8, [r6, #4]    // load the number of characters in the word to r8
    @sub r8, r8, #65536  // subtract 65536 from r8 to convert the ASCII value to the actual number of characters
    
    cmp r8, r4 // if number of characters are the same, compare the word
    beq compare_words // if yes, jump to compare_words
    
    add r6, r6, #16  // if not equal number of characters, move to the next word in the dictionary
    
    b search_word // jump to search_word (recursive)

compare_words:

    mov r0, #0   // word index 0 for comparison with r4
    ldr r5, =word  // load initial address of the word to r5
    ldr r8, [r6]    // load the initial address of the word in the dictionary to r8

    b compare_words_loop // jump to compare_words_loop

compare_words_loop:   
    cmp r0, r4 // check if all characters are compared, if yes, adds to the frequency.
    beq frequency_increase // if yes, jump to frequency_increase

    ldrb r2, [r5, r0] // load the character from the word buffer to r2
    ldrb r3, [r8, r0] // load the character from the dictionary word buffer to r3

    add r0, r0, #1 // increment the word index by 1
    
    cmp r2, r3 // compare the characters, if equal, keep comparing characters
    beq compare_words_loop // if yes, jump to compare_words_loop (keep recursive)
    
    add r6, r6, #16 // if not equal, stop comparing, and search for other words in the dictionary
    b search_word // jump to search_word

frequency_increase: // adds 1 to the frequency of the word in the dictionary
    
    ldr r2, [r6, #8]  // load the frequency of the word in the dictionary to r2
    add r2, r2, #1     // increment the frequency by 1
    str r2, [r6, #8]  // store the frequency to the dictionary

    ldr r3, =dictionary // load the address of the dictionary
    b order_by_frequency // jump to order_by_frequency

order_by_frequency: // rearranges the dictionary by frequency in descending order
    cmp r6, r3 // check if it is the end of the dictionary
    beq order_by_frequency_out // if yes, jump to order_by_frequency_out

    sub r6, r6, #16     // move dictionary index to the previous word
    ldr r7, [r6, #8]  // load the frequency of the previous word to r7
    ldr r2, [r6, #24]  // load the frequency of the current word to r2
    
    cmp r7, r2 // compare the frequencies of the previous and current words
    blt move_word_by_frequency // if the previous word has a lower frequency, move the current word to the previous word 

    bx lr // return (end of function)
    
move_word_by_frequency: // moves the word in the dictionary by frequency in descending order

    ldr r0, [r6] // load the initial address of the previous word to r0
    ldr r2, [r6, #16] // load the initial address of the current word to r2

    str r0, [r6, #16] // store the previous word to the current word
    str r2, [r6]      // store the current word to the previous word

    ldrb r0, [r6, #4]  // load the number of characters in the previous word to r0
    ldrb r2, [r6, #20] // load the number of characters in the current word to r2

    strb r0, [r6, #20] // store the number of characters in the previous word to the current word
    strb r2, [r6, #4]  // store the number of characters in the current word to the previous word

    ldr r0, [r6, #8] // load the frequency of the previous word to r0
    ldr r2, [r6, #24] // load the frequency of the current word to r2

    str r0, [r6, #24] // store the frequency of the previous word to the current word
    str r2, [r6, #8] // store the frequency of the current word to the previous word

    b order_by_frequency // jump to order_by_frequency (recursive)


order_by_frequency_out: // returns to the main function
    bx lr // return (end of function)

add_new_word: // adds the word to the dictionary
    // obtains the memory address of the word (buffer index + (character - 1))
    mov r8, r12     // store the address of the word to r8
    sub r8, r8, r4  // subtract the number of characters in the word from the address of the word to get the initial address of the word
    sub r8, r8, #1  // subtract 1 from the initial address of the word to get the initial address of the word

    str r8, [r10] // store the initial address of the first character of the word to the dictionary

    str r4, [r10, #4] // store the number of characters in the word to the dictionary

    mov r8, #1 // initialize the frequency of the word to 1
    str r8, [r10, #8] // store the frequency of the word to the dictionary

    add r10, r10, #16 // increment the dictionary index by 16 to move to the next word

    bx lr // return (end of function)

file_open_error:
    ldr r1, =open_error // load the address of the open_error message  
    b end

file_read_error:
    ldr r1, =read_error // load the address of the read_error message 

end:

    mov r7, #1    // exit system call      
    swi 0   // make the system call
    