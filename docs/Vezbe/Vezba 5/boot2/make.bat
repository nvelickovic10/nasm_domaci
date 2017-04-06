@echo off
rem    Prevodimo program za pravljenje boot sektora
nasm pb.asm -f bin -o pb.com

rem    Prevodimo boot sektor za FAT12 i FAT16
nasm boot12.asm -f bin -o boot12.sys
nasm boot16.asm -f bin -o boot16.sys

rem    Prevodimo primer za COM startup datoteku
nasm com.asm -f bin -o startup.com

rem    Prevodimo primer za EXE startup datoteku
nasm exe.asm -f obj -o startup.obj
tlink startup.obj, startup.exe > nul

rem    Nakon izvrsenja ovog skripta, staviti formatiranu
rem    disketu u jedinicu A (ili virtuelnu disketu u jedinicu A,
rem    ako se radi sa virtuelnom masinom), a zatim zadati komande:
rem
rem    pb boot12.sys
rem    copy startup.com a:startup.bin za COM primer, ili
rem    copy startup.exe a:startup.bin za EXE primer
rem 
rem    i nakon toga restartovati racunar (virtuelnu masinu)    

