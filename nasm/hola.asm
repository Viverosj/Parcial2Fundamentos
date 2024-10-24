section .data
    msg_intro db "Bienvenido a la calculadora en ensamblador (RPN)", 0xA, 0xD               
    prompt_num db "Ingrese dos numeros en RPN separados por espacio: ", 0xA, 0xD
    prompt_op db "Ingrese la operación a realizar (+, -, *, /, %): ", 0xA, 0xD
    error_zero db "Error: DIvisión por cero", 0xA, 0xD
    msg_res db "Resultados: ", 0xA, 0xD
    exit_msg db "Esriba 'exit' para salir o cualquier tecla para continuar.", 0xA, 0xD

section .bss 
    buffer resb 30                                          ;Espacio para leer la entrada del ususario
    num_stack resd 10                                       ;Espacio para una pila de números (máximo 10 números)
    stack_ptr resb 1                                        ;Puntero de la pila

section .text 
    global _start                                           ;Se hace la etiqueta _start global para que sea el punto de entrada

_start:                                                     ; Muestra la bienvenida
    mov eax, 4                                              ;Código del sistema (sys_write, para escribir)
    mov ebx, 1                                              ;File descriptor (1 = salida estandar de la pantalla)
    mv ecx, msg_intro                                       ;Dirección de la cadena de texto del mensaje de entrada
    mov edx, 47                                             ;Longitud de la cadena (37 caracteres)
    int 0x80                                                ;Llamada a la interrupción del sistema

loop:                                                       ; Solicitar los números
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt_num                                     ;Dirección de la cadena de texto del mesnaje para ingresar dos números
    mov edx, 49
    int 0x80

    ; Leer entrada del usuario
    mov eax, 3
    mov ebx, 0
    mov ecx, buffer
    mov edx, 30
    int 0x80

    ; Inicializar el puntero de la pila
    mov byte [stack_ptr], 0

    ; Se parsea y procesa la entrada en RPN
    mov esi, buffer                                         ;Apuntar a la entrada
    
parse_input:
    mov al, [esi]                                           ;Leer caracyer actual
    cmp al, 0x20                                            ;Comprueba si es un espacio
    je next_char                                            ;Ignora los espacios


    cmp al, 0x0A                                            ;Comprueba si es un salto de línea (Fin de la emtrada)
    je mostrar_res

    ; verifica si es un operador o un número
    cmp al, '0'
    jl check_operator                                       ;Si es menor que 0 debe ser un operador
    cmp al, '9'                                             
    jg check_operator                                       ;Si es mayor que 9 debe ser un operador

    ; Es un número, convertir y pushear a la pila
    sub al, '0'                                             ;Convertir de ASCII a número
    call push_stack
    jmp next_char

check_operator:
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
    mov edx, 25
    int 0x80
    jmp loop

    mostrar_res:
    add eax, '0'
    mov [result], eax

    mov eax, 4
    mov ebx, 1
    mov ecx, msg_res
    mov edx, 12
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, result
    mov edx, 1
    int 0x80

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

    cmp dword [buffer], 0x747865
    je salir

    jmp loop

    salir:

    mov eax, 1
    mov ebx, 0
    int 0x80



