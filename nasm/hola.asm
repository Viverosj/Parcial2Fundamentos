section .data
    msg_intro db "Bienvenido a la calculadora en ensamblador (RPN)", 0xA, 0xD               
    prompt_num1 db "Ingrese el primer número: ", 0xA, 0xD
    prompt_num2 db "Ingrese el segundo número: ", 0xA, 0xD
    prompt_op db "Ingrese la operación a realizar (+, -, *, /, %): ", 0xA, 0xD
    error_zero db "Error: División por cero", 0xA, 0xD
    error_op db "Error: División por cero", 0xA, 0xD
    msg_res db "Resultado: ", 0xA, 0xD
    exit_msg db "Esriba 'exit' para salir o cualquier tecla para continuar.", 0xA, 0xD

section .bss 
    num1 resb 10
    num2 resb 10
    result resb 10
    buffer resb 30                                          ;Espacio para leer la entrada del ususario
    operation resb 2

section .text 
    global _start                                           ;Se hace la etiqueta _start global para que sea el punto de entrada

_start:                                                     ; Muestra la bienvenida
    mov eax, 4                                              ;Código del sistema (sys_write, para escribir)
    mov ebx, 1                                              ;File descriptor (1 = salida estandar de la pantalla)
    mv ecx, msg_intro                                       ;Dirección de la cadena de texto del mensaje de entrada
    mov edx, 36                                             ;Longitud de la cadena (37 caracteres)
    int 0x80                                                ;Llamada a la interrupción del sistema

loop:                                                       ; Solicitar los números
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt_num1                                     ;Dirección de la cadena de texto del mesnaje para ingresar dos números
    mov edx, 26
    int 0x80

    ; Leer entrada del usuario
    mov eax, 3
    mov ebx, 0
    mov ecx, num1
    mov edx, 10
    int 0x80
    call parse_number1                                      ;Convertir la entrada en número

    ; Solicitar el segundo número 
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt_num2
    mov edx, 26
    int 0x80

    ;Leer el segundo número
    mov eax, 3
    mov ebx, 0
    mov ecx, num2mov edx, 10
    int 0x80
    call parse_number2                                      ;Convertir la entrada en número

    ; SOlicitar la operación
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt_op
    mov edx, 35
    int 0x80

    ; Leer la operación
    mov eax, 3
    mov ebx, 0
    mov ecx, operation
    mov edx, 2
    int 0x80

    ; Realizar la operación
    mov al, [operation]
    cmp al, '+'
    je suma
    cmp al, '-'
    je resta
    cmp al, '*'
    je multiplicacion
    cmp al, '/'
    je division
    cmp al, '%'
    je modulo

    ;Si no es un operador válido, mostrar error
    mov eax, 4
    mov ebx, 1
    mov ecx, error_op
    mov edx, 24
    int 0x80
    jmp loop

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
    mov edx, 23
    int 0x80
    jmp loop

    mostrar_res:
    add eax, '0'
    mov [result], eax

    mov eax, 4
    mov ebx, 1
    mov ecx, msg_res
    mov edx, 11
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, result
    mov edx, 1
    int 0x80

    ;Preguntar si el usuario desea continuar
    mov eax, 4
    mov ebx, 1
    mov ecx, exit_msg
    mov edx, 60
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, buffer
    mov edx, 4
    int 0x80

    cmp dword [buffer], 0x747865  ;Comprobar si el usuario escribio "exit"
    je salir

    jmp loop

    salir:

    mov eax, 1
    mov ebx, 0
    int 0x80

    ;Convertir las entradas
    parse_number1:
        ;Convierte el número en num1 de ASCII a ENTERO (Incluye signo Negativo)
        ;Aqui se considera el primer caracter como posible signo Negativo
        mov esi, num1
        xor eax, eax
        xor ebx, ebx
        mov bl, [esi]       ;Primer Caracter
        cmp bl, '-'
        jne parse_positive1
        inc esi             ;Si es negativo, avanzar el puntero
        call parse_digits1
        neg eax             ;Hace el numero negativo
        ret 
    
    parse_positive1:
        call parse_digits1
        ret

    parse_digits1:
        ;Convierte los caracteres en número
        mov ecx, 10
    convert_loop1:
        mov bl, [esi]
        cmp bl, 0xA         ;Fin de la linea
        je end_parse1
        sub bl, '0'
        imul eax, ecx
        add eax, ebx
        inc esi
        jmp convert_loop1
    end_parse1:
        mov[num1], eax
        ret

    parse_number2:
        mov esi, num2
        xor eax, eax
        xor ebx, ebx
        mov bl, [esi]
        cmp bl, '-'
        jne parse_positive2
        inc esi
        call parse_digits2
        neg eax
        ret

    parse_positive2:
        call parse_digits2
        ret

    parse_digits2:
        mov ecx, 10
    convert_loop2:
        mov bl, [esi]
        cmp bl, 0xA
        je end_parse2
        sub bl, '0'
        imul eax, ecx
        add eax, ebx
        inc esi
        jmp convert_loop2
    end_parse2:
        mov[num2], eax
        ret