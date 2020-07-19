#!/bin/bash

yasm -gdwarf2 -felf64 src/main.asm -o build/main.o
yasm -gdwarf2 -felf64 src/printString.asm -o build/printString.o
yasm -gdwarf2 -felf64 src/sleep.asm -o build/sleep.o
yasm -gdwarf2 -felf64 src/input.asm -o build/input.o
yasm -gdwarf2 -felf64 src/clearScreen.asm -o build/clearScreen.o

ld -g build/*.o -o build/Snake
