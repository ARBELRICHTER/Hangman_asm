;HANGMAN_ASSEMBLY_PROJECT

IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
;the_word db 'father', '$'
the_word db 30 dup (?)

stage0_pic db ' x-------x', 10, 13, ' |', 10, 13, ' |', 10, 13, ' |', 10, 13, ' |', 10, 13, ' |', 10, 13, '$'
stage1_pic db ' x-------x', 10, 13, ' |', '       ', '|', 10, 13, ' |', '       ', '0', 10, 13, ' |', 10, 13, ' |', 10, 13, ' |', 10, 13, '$'
stage2_pic db ' x-------x', 10, 13, ' |', '      ', ' |', 10, 13, ' |', '       ', '0', 10, 13, ' |', '       ', '|', 10, 13, ' |', 10, 13, ' |', 10, 13, '$'
stage3_pic db ' x-------x', 10, 13, ' |', '      ', ' |', 10, 13, ' |', '       ', '0', 10, 13, ' |', '      ', '/', '|', 10, 13, ' |', 10, 13, ' |', 10, 13, '$'
stage4_pic db ' x-------x', 10, 13, ' |', '       ', '|', 10, 13, ' |', '       ', '0', 10, 13, ' |', '      ', '/', '|', '\', 10, 13, ' |', 10, 13, ' |', 10, 13, '$'
stage5_pic db ' x-------x', 10, 13, ' |', '       ', '|', 10, 13, ' |', '       ', '0', 10, 13, ' |', '      ', '/', '|', '\', 10, 13, ' |', '      ', '/', 10, 13, ' |', 10, 13, '$'
stage6_pic db ' x-------x', 10, 13, ' |', '      ', ' |', 10, 13, ' |', '       ', '0', 10, 13, ' |', '      ', '/', '|', '\', 10, 13, ' |', '      ', '/', ' ', '\', 10, 13, ' |', 10, 13, '$'

;messages
correct_msg db 'correct!', 10, 13, '$'
wrong_msg db 'wrong!', 10, 13, '$'
lose_msg db 'You lost!', 10, 13, '$'
win_msg db 'You won!', 10, 13, '$'
already_guessed_msg db 'this letter was already guessed before. Try again.', 10, 13, '$' 
guess_msg db 'guess a letter:', '$'
notalpha_msg db 'You need to guess a letter. Try again.', 10, 13, '$'
the_word_was_msg db 'The word was: ', '$'
letters_already_guessed_msg db 'Letters you guessed: ', '$'
hangman_msg db ' _    _', 10, 13,  '| |  | |', 10, 13, '| |__| | __ _ _ __   __ _ _ __ ___   __ _ _ __  ', 10, 13, '|  __  |/ _` | _  \ / _` | _ ` _  \ / _` | _  \ ', 10, 13, '| |  | | (_| | | | | (_| | | | | | | (_| | | | |', 10, 13, '|_|  |_|\__,_|_| |_|\__, |_| |_| |_|\__,_|_| |_|', 10, 13, '                     __/ |                      ', 10, 13, '                    |___/', 10, 13, '$'
beginning_msg db 'WELCOME TO THE GAME HANGMAN!', 10, 13, ' These are the rules: there is a hidden word, and you need to guess what it      is. In each turn you may guess one letter. You have 6 tries, good luck!', 10, 13, '*if you want to exit the game, press backspace.', 10, 13, 10, 13, '                         -press any key to begin-', 10, 13, '$'
invalid_input_msg db 'Please enter a number from 1 to 9: ', '$'

;arrays
lines_var db 30 dup (?);var of lines and spaces
word_list db 4, "hang", 3, "man", 5, "hello", 11, 'personality', 6, 'father', 6, 'orange', 5, 'shark', 7, 'partner', 8, 'assembly', '$'
letter_guessed_list db 28 dup (?)
sorted_arr db 30 dup (?) ;the array will contain all word sorted

;db variables

;dw variables
word_length dw 6
letter_guessed dw 'b'
save_bx dw 0
save_dx dw 0
final_counter db 0
correct_letters_guessed_cnt dw 0
amount_of_letters_guessed dw 0
random_number dw 0
; --------------------------

CODESEG
; -----------------------------------------------------------------------------------
	proc choose_word
		;need to push: 1. offset the_word 2. random_number, 3. offset word_list
		;the func will choose a word form the list according to the given number
		push bp
		mov bp, sp
		mov dx, [bp+6]; dx has the needed index
		mov si, [bp+4]; si has the offset of word_list
		mov bx, 0
		countloop1:
			mov ax, [bx+si]
			cmp al, 20
			jg not_number
			dec dx
			not_number:
			inc bx
			cmp dx, 0
			je exit_loop
			jmp countloop1
			cmp bx, 100
			je exit_loop
		exit_loop:
		mov ah, 0
		mov [word_length], ax
		mov cx, ax; cx has the length of the chosen word
		mov dx, cx
		mov di, [bp+8]; di has offset the_word
		the_word_loop:
			mov al, [bx+si]; al has the letter of the chosen word
			mov [save_dx], dx
			sub dx, cx
			mov [save_bx], bx
			mov bx, dx
			mov [di+bx], al
			mov bx, [save_bx]
			inc bx
			mov dx, [save_dx]
		loop the_word_loop
		mov bx, [save_dx]
		mov [byte ptr bx+di], '$'
		pop bp
		ret 6
	endp choose_word
	; -----------------------------------------------------------------------------------
	proc lines_and_spaces; 
		;need to push the_word_size variable before calling this func
		;function prints lines instead of letters of the word
		mov bx, 0
		push bp
		mov bp, sp
		mov cx, [bp+6]
		mov si, [bp+4]
		linespace:
			mov dl, '_'
			mov [si+bx], dl
			inc bx
			mov dl, ' '
			mov [si+bx], dl
			inc bx
		loop linespace
		mov [byte ptr si+bx], 10
		mov [byte ptr si+bx+1], 13
		mov [byte ptr si+bx+2], '$'
		pop bp
		ret 4
	endp lines_and_spaces
; -----------------------------------------------------------------------------------
	proc stage
		;need to push offset stagex_pic, x according to situation
		push bp
		mov bp, sp
		mov dx, [bp+4]
		mov ah, 9
		int 21h
		pop bp
		ret 2
	endp stage
; -----------------------------------------------------------------------------------
	proc is_letter_in_word
		;need to push the 1.guessed_letter 2. offset of the word 3.word length
		;the function puts 1 in dx if the letter is in the word, otherwise 0.
		push bp
		mov bp, sp
		mov si, [bp+6]; si contains the word's offset
;		mov si, 8
		mov bx, 0
		mov dl, [bp+8]; dx contains the guessed letter
		mov cx, [bp+4]; initiating the counter to be the size of the word
		cooloop:
			mov ax, [bx+si]
			cmp al, dl
			je in_word
			inc bx
		loop cooloop
		mov dx, 0
		jmp next
		in_word:
			mov dx, 1
		next:
		pop bp
		ret 6
	endp is_letter_in_word
; -----------------------------------------------------------------------------------
	proc was_letter_guessed_before
		;push: 1. offset already_guessed_msg, 2. offset letter_guessed_list, 3. letter_guessed
		;dx is 1 if the letter was guessed before, otherwise 0
		push bp
		mov bp, sp
		mov cx, 26; 26 iterations for each english letter
		mov si, [bp+6]; si has the offset of letter_guessed_list
		mov bx, 0
		mov dl, [bp+4]
		cloop:
			mov ax, [bx+si]
			cmp al, dl;comparing each letter in the list to the guessed letter
			je msg
			inc bx
		loop cloop
		mov dx, 0
		jmp next
		msg:
			mov dx, [bp+8]
			mov ah, 9
			int 21h
			mov dx, 1; dx is 1 if the letter was alredy guessed
		finish:
		pop bp
		ret 6
	endp was_letter_guessed_before	
; -----------------------------------------------------------------------------------
	proc update
		;the function should update the lines_var when the letter is guessed correctly, that is if is_letter_in_word returns 1 in dx
		;parameters to push:  1. lines_var offset10, 2. the_word offset8 3. guessed_letter6 4. word_length4	
		push bp
		mov bp, sp
		
		mov cx, [bp+4];cx has the word length
		mov si, [bp+8]; si contains the word's offset
		mov di, [bp+10]; di contains lines_var offset
		mov bx, 0
		mov dx, 0
		checkloop:
			;go over every letter in word, find out the index
			;then go over every char in lines_var, replace the index*2
			mov ax, [bx+si]; al contains each letter at the time
			mov ah, [bp+6]; ah contains the correctly guessed letter
			cmp al, ah
;			mov dx, [bp+10]; dx 
;			mov [bp+10], al ;contains the counter
			mov [save_bx], bx
;			mov [word ptr bp+10], bx; bp+10 holds bx for now
			mov bx, 0
			je right_index
			jmp next_letter
			right_index:;the index of the letter is bx
				mov ax, [save_bx]; al holds the right index
				mov ah, 2
				mul ah; ax becomes the right index in lines_var to replace
				mov dx, ax; now dx holds the right index
				cmp dx, bx; if they are equal, it is the right index
				mov ax, [bx+di]
				je update_letter
				jmp continue
					update_letter:
					mov ax, [bp+6]; ax has the guessed letter
				continue:
				mov [bx+di], ax
				add bx, 2
				mov ah, [bp+4]; ah has the word length
				mov al, 2
				mul ah; ax contains the lines_var length
				cmp bx, ax; to prevent infinite loop
				je next_letter
				jmp right_index
			next_letter:
			mov bx, [save_bx]
			inc bx
		loop checkloop
		pop bp
		ret 10
	endp update
; -----------------------------------------------------------------------------------
	proc update_guessed_letter_list
		;push: 1. letter_guessed, 2. offset letter_guessed_list, 3. amount_of_letters_guessed
		;the func updates the letter_guessed_list. it adds the guessed letter
		push bp
		mov bp, sp
		mov si, [bp+6] ;si has the offset of letter_guessed_list
;		mov bx, 0
		mov bx, [bp+4]; bx has the length of the letter_guessed_list
		mov ax, [bp+8]
		mov [bx+2+si], ax
		mov [byte ptr bx+3+si], '$'
		pop bp
		ret 6
	endp update_guessed_letter_list
; -----------------------------------------------------------------------------------
	proc how_many_times_letter_showed
		;need to push: 1. word_length, 2. offset the_word, 3. letter_guessed
		;puts in dx the amount of times a letter showed up in the word
		push bp
		mov bp, sp
		mov cx, [bp+8]
		mov si, [bp+6]
		mov bx, 0
		mov dx, 0
;		mov al, [bp+4]; ax has the letter guessed
		counting_loop:
			mov ax, [bx+si]
			cmp [bp+4], al
			je increase
			jmp continue_counting_loop
			increase:
			inc dx
		continue_counting_loop:
		inc bx
		loop counting_loop
		pop bp
		ret 6
	endp how_many_times_letter_showed
; -----------------------------------------------------------------------------------
	proc lower
		;need to push letter_guessed
		push bp
		mov bp, sp
		mov ax, [bp+4]
		cmp ax, 91
		jl lowercase
		jmp end_of_lower
		lowercase:
		add ax, 32
		end_of_lower:
		mov [bp+4], ax
		pop bp
		ret 2
	endp lower
; -----------------------------------------------------------------------------------
	proc isalpha
		;need to push letter_guessed
		;checks if the input is a letter. puts 1 in dx if not
		push bp
		mov bp, sp
		mov ax, [bp+4]
		cmp ax, 97
		jl not_alpha
		cmp ax, 122
		jg not_alpha
		mov dx, 0
		jmp end_of_func
		not_alpha:
			mov dx, [bp+6]
			mov ah, 9
			int 21h
			mov dx, 1
		end_of_func:
		pop bp
		ret 2 
	endp isalpha
; -----------------------------------------------------------------------------------
	proc print_letter_list
		;need to push: 1. offset letters_already_guessed_msg, 2. amount_of_letters_guessed, 3. offset letter_guessed_list
		;the func prints the letter_guessed_list with commas
		push bp
		mov bp, sp
		mov cx, [bp+6]
		mov si, [bp+4]
		mov bx, 0
		mov dx, [bp+8]
		mov ah, 9
		int 21h
		print_loop:
			mov dl, [bx+si+2]
			mov ah, 2
			int 21h
			cmp cx, 1
			je end_print_letter_list
			mov dl, ','
			mov ah, 2	
			int 21h
			inc bx
		loop print_loop
		end_print_letter_list:
		mov dl, 10
		mov ah, 2
		int 21h
		mov dl, 13
		mov ah, 2
		int 21h
		pop bp
		ret 6
	endp print_letter_list
; -----------------------------------------------------------------------------------
	proc new_line
		mov dl, 10
		mov ah, 2
		int 21h
		mov dl, 13
		mov ah, 2
		int 21h
		ret
	endp new_line
; -----------------------------------------------------------------------------------
	proc convinient_clear
		mov ax, 3
		int 10h
		
		mov dx, offset hangman_msg
		mov ah, 9
		int 21h
		ret
	endp convinient_clear
; -----------------------------------------------------------------------------------
; ***********************************************************************************
; ***********************************************************************************
; -----------------------------------------------------------------------------------
	start:
	mov ax, @data
	mov ds, ax
; --------------------------
	jmp begin
	
	exit_stp:
	jmp exit
	
	begin:
	;clear screen:
	mov ax, 3
	int 10h
	mov dx, offset hangman_msg
	mov ah, 9
	int 21h
	
	mov dx, offset beginning_msg
	mov ah, 9
	int 21h
	
	mov ah, 1
	int 21h
	mov ah, 0
	cmp ax, 9; not exiting the program
	je exit_stp

	invalid_input:
	call new_line
	mov dx, offset invalid_input_msg
	mov ah, 9
	int 21h
	
	take_letter:
	mov ah, 1
	int 21h
	sub al, 30h
	mov ah, 0
	cmp ax, 9
	jg invalid_input
	cmp ax, 0
	je invalid_input
	mov [random_number], ax
	push offset the_word
	push [random_number]
	push offset word_list
	call choose_word
	
	mov ax, 3
	int 10h
	
	mov dx, offset hangman_msg
	mov ah, 9
	int 21h
	
	push [word_length]
	push offset lines_var
	call lines_and_spaces	
	
	push offset stage0_pic
	call stage
	
	mov dx, offset lines_var
	mov ah, 9
	int 21h
	
	call new_line
	
	;This is where the game begins
	finaloop:
		mov dx, offset guess_msg
		mov ah, 9
		int 21h
		mov ah, 1
		int 21h; al contains the guessed_letter
		mov ah, 0
		cmp ax, 8
		je near_exit
		jmp moving_on
		near_exit:
		mov ax, 3
		int 10h
		jmp exit
		moving_on:
		mov [letter_guessed], ax
		call convinient_clear
		call new_line
		
		;lowercasing the letter
		push [letter_guessed]
		call lower
		mov [letter_guessed], ax
		
		;here we check if the input is valid
		push offset notalpha_msg
		push [letter_guessed]
		call isalpha
		cmp dx, 1
		jne donot_print_stp
		
		calling:
;		call convinient_clear
		cmp [final_counter], 0
		je stage000
		cmp [final_counter], 1
		je stage111
		cmp [final_counter], 2
		je stage222
		cmp [final_counter], 3
		je stage333
		cmp [final_counter], 4
		je stage444
		cmp [final_counter], 5
		je stage555
		
		donot_print_stp:
		jmp donot_print
		
		stage000:
		push offset stage0_pic
		jmp call_stage1
		stage111:
		push offset stage1_pic
		jmp call_stage1
		stage222:
		push offset stage2_pic
		jmp call_stage1
		stage333:
		push offset stage3_pic
		jmp call_stage1
		stage444:
		push offset stage4_pic
		jmp call_stage1
		stage555:
		push offset stage5_pic

		call_stage1:
		call new_line
		push offset letters_already_guessed_msg
		push [amount_of_letters_guessed]
		push offset letter_guessed_list
		call print_letter_list
		mov dx, offset lines_var
		mov ah, 9
		int 21h
		call stage
		jmp finaloop
		donot_print:
		
		;checking if the letter was guessed before
		push offset already_guessed_msg
		push offset letter_guessed_list
		push [letter_guessed]
		call was_letter_guessed_before
		cmp dx, 1
		jne updating
		
		calling_stp:
		call convinient_clear
		call new_line
		mov dx, offset already_guessed_msg
		mov ah, 9
		int 21h
		jmp calling
		
		updating:
		;updating the letter_guessed_list 
		push [letter_guessed]
		push offset letter_guessed_list
		push [amount_of_letters_guessed]
		call update_guessed_letter_list
		inc [amount_of_letters_guessed]
		
		;checking if the letter is in the word
		push [letter_guessed]
		push offset the_word
		push [word_length]
		call is_letter_in_word
		cmp dx, 1
		je correct
		
		;you're here if the letter is not in the word
		mov dx, offset wrong_msg
		mov ah, 9
		int 21h
		call new_line
		jmp next_guess
		
		;you're here if the letter is in the word
		correct:
			mov dx, offset correct_msg
			mov ah, 9
			int 21h
			call new_line
			push offset lines_var; updating lines_var with the new letter
			push offset the_word
			push [letter_guessed]
			push [word_length]
			call update
			
			push offset letters_already_guessed_msg
			push [amount_of_letters_guessed]
			push offset letter_guessed_list
			call print_letter_list

			mov dx, offset lines_var
			mov ah, 9
			int 21h
			
			cmp [final_counter], 0
			je stage0
			cmp [final_counter], 1
			je stage11
			cmp [final_counter], 2
			je stage22
			cmp [final_counter], 3
			je stage33
			cmp [final_counter], 4
			je stage44
			cmp [final_counter], 5
			je stage55
			
			stage0:
			push offset stage0_pic
			jmp after_stage
			stage11:
			push offset stage1_pic
			jmp after_stage
;			jmp continue_loop
			stage22:
			push offset stage2_pic
			jmp after_stage
;			jmp continue_loop
			stage33:
			push offset stage3_pic
			jmp after_stage
;			jmp continue_loop
			stage44:
			push offset stage4_pic
			jmp after_stage
;			jmp continue_loop
			stage55:
			push offset stage5_pic
;			jmp continue_loop
			after_stage:
			call stage

			push [word_length]
			push offset the_word
			push [letter_guessed]
			call how_many_times_letter_showed
			
			add [correct_letters_guessed_cnt], dx
			mov dx, [correct_letters_guessed_cnt]
			cmp dx, [word_length]
			je win_stp
			jmp finaloop
		
		next_guess:
		push offset letters_already_guessed_msg
		push [amount_of_letters_guessed]
		push offset letter_guessed_list
		call print_letter_list
		mov dx, offset lines_var
		mov ah, 9
		int 21h
		inc [final_counter]
		cmp [final_counter], 1
		je stage1
		cmp [final_counter], 2
		je stage2
		cmp [final_counter], 3
		je stage3
		cmp [final_counter], 4
		je stage4
		cmp [final_counter], 5
		je stage5
		cmp [final_counter], 6
		je lose
		jmp continue_loop
			win_stp:
			jmp win
		stage1:
		push offset stage1_pic
		jmp continue_loop
		stage2:
		push offset stage2_pic
		jmp continue_loop
		stage3:
		push offset stage3_pic
		jmp continue_loop
		stage4:
		push offset stage4_pic
		jmp continue_loop
		stage5:
		push offset stage5_pic
 		jmp continue_loop
		
	win:
	mov dx, offset win_msg
	mov ah, 9
	int 21h
	jmp exit
	continue_loop:	
	call stage
	jmp finaloop
	
	lose:
	push offset stage6_pic
	call stage

	mov dx, offset the_word_was_msg
	mov ah, 9
	int 21h
	
	mov dx, offset the_word
	mov ah, 9
	int 21h
	
	call new_line
	mov dx, offset lose_msg
	mov ah, 9
	int 21h

; --------------------------
	
exit:
	mov ax, 4c00h
	int 21h
END start


