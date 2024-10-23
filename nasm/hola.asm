section .data
    msg_intro db "Bienvenido a la calculadora en ensamblador (RPN)", 0xA, 0xD
    prompt_num db "Ingrese dos numeros en RPN separados por espacio: ", 0xA, 0xD
    prompt_


    Suma:
    mov eax, [num1]
    add eax, [num2]
    jmp mostrar_res

    resta:
    mov eax, [num1]
    sub eax, [num2]
    jmp mostrar_res

    multiplicacion:
    mov eax, [num1]
    imul eax, [num2]
    jmp mostrar_res

    division:
    mov eax, [num2]
    cmp eax, 0
    je error_div_cero
    mov eax, [num1]
    cdq
    idiv dword[num2]
    jmp mostrar_res

    modulo:
    mov eax,[num2]
    cmp eax,0
    je error_div_cero
    mov eax,[num1]
    cdq
    idiv dword[num2]
    mov eax, edx
    jmp mostrar_res

    error_div_cero:
    mov eax, 4
    mov ebx, 1
    mov ecx, error_zero
    mov edx, 25
    int 0x80
    jmp loop

    mostrar_res:
    add eax, '0'
    mov [result], eax

    mov eax, 4
    mov ebx, 1
    



