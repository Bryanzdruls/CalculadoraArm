@ falta validacion de signos 
	.data
n1:	.word 0x00000012
n2:	.word 0x00000000
aux: 	.word 0x00000000
error0: .ascii "error div no se puede por 0\n"
	.text
main:	ldr r0, =n1
	ldr r1, =n2

	ldr r0, [r0]
	ldr r1, [r1]

	bl suma
	bl resta
	bl mult
	@Se reinician los registros
	@para el cociente, la parte entera se almacena en r4 y primer decimal en r6, segundo decimal en r3
	ldr r0, =n1
	ldr r1, =n2
	ldr r0, [r0]
	ldr r1, [r1] 
	mov r2, #0
	mov r3, #0
	@COMPARAR SIGNOS ANTES DE DIVIDIR
seguir:	cmp r0 ,r6	@Se verifica si el r0 es negativo
	bmi neg0
	
	cmp r1 ,r6 	@Se verifica si el r1 es negativo
	bmi neg1

	sub r2, r1, #0
	beq printS
	bl div

	ldr r7,=aux	@se almacena en r7 la direccion de aux
	str r0,[r7]	@Se almacena r0 en la direccion de r7 para poder comparar mas adelante

	mov r4, r3 @copia de la parte entera del cociente
	bl residuo @se calcula el residuo, se almacena en r4  
	mov r6, r3
	bl residuo
	
	b signo	

print: 	mov r7, r4 	@se ordenan los registros para poderlos imprimir
	mov r6, r6	@se ordenan los registros para poderlos imprimir
	mov r5, r3	@se ordenan los registros para poderlos imprimir
	mov r4, #0	@se ordenan los registros para poderlos imprimir
	mov r3, #0	@se ordenan los registros para poderlos imprimir
	

stop: 	wfi

suma:	add r2, r0, r1
      	mov pc, lr

resta:	sub r3, r0, r1
	mov pc, lr

mult:	mul r0, r0, r1
	mov pc, lr


div:	mov r2, r0 	
cont:	b restaS	@resta sucesiva
cte:	mov pc, lr	

restaS:	sub r2, r2, r1
	bmi cte    	@el contador no sigue sumando
	add r3, r3, #1	
	b cont

residuo: mul r3, r3, r1 
	 cmp r3, r0
         beq resulD	@como son iguales, el resultado es un cociente entero.
	 sub r5, r0, r3
	 mov r7, #10
	 mul r5, r5, r7
	 mov r3, #0
	 mov r0, r5
	 b div

resulD: mov r3, #0
	b signo

neg0: 	neg r0,r0	@se niega el valor negativo para volverlo positivo y que sea admitido por la calculadora
	b seguir
neg1:	neg r1,r1	@se niega el valor negativo para volverlo positivo y que sea admitido por la calculadora
	b seguir

signo:	ldr r0, =aux
	ldr r0, [r0] 	@se almacena el valor negado de r0 que sse encuentra en aux nuevamente en r0

	ldr r7, =n1	
	ldr r7, [r7]	@se almacena el valor original del r0 en r7

	ldr r5, =n2
	ldr r5, [r5]	@se almacena el valor original del r1 en r5
	
comp:	cmp r0, r7	@se compara si los dos numeros son iguales, de caso contrario significa que r0 era negativo	
	bne cambio
	cmp r1, r5	@se compara si los dos numeros son iguales, de caso contrario significa que r1 era negativo	   
	bne cambio1
	b print

cambio:
	neg r4, r4	@se niega el resultado en caso que sea negativo
	mov r0, r7	@se pone el registro en el valor original
	b comp

cambio1:
	neg r4, r4	@se niega el resultado en caso que sea negativo
	mov r1, r5	@se pone el registro en el valor original
	b comp

printS: mov r0, #1
	mov r1, #1
	 ldr r2, = error0
	bl printf
	b stop
