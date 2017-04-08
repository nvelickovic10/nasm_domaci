ESC equ 1bh                                 ; ASCII kod za Esc taster
ENT equ 0dh                                 ; ASCII kod za Ent taster
SEP equ 25h                                 ; ASCII kod za $ (terminator)
SPA equ 20h                                 ; ASCII kod za Spa tqaster

org 100h

segment .code
main:
  call cls

  call get_args     

  mov si, command
  mov di, komanda_start
  call compare_strings
  cmp ax, 1
  je .start_timer

  mov si, command
  mov di, komanda_stop
  call compare_strings
  cmp ax, 1
  je .stop_timer

  mov si, msg_badargs
  jmp .end

.start_timer:
  mov si, msg_start
  jmp .end

.stop_timer:
  mov si, msg_stop

.end:
  call print
  ret

segment .data
command: db '      ',SEP
time: db '        ',SEP

msg_badargs: db 'ne valjhaju argumenti',SEP
msg_start: db 'starting timer',SEP
msg_stop: db 'stopping timer',SEP
noargs: db 'noargs',SEP

komanda_start: db '-start',SEP
komanda_stop: db '-stop',SEP

%include "_video.asm"
%include "_string.asm"
%include "_args.asm"
