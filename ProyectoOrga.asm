.data
	titulo: .asciiz "\n---------------------Proyecto Organización y Arquitectura de Computadores---------------------\n     -----------------------------------Primer Parcial-----------------------------------\n"
	menuString: .asciiz "\nIngrese una opción del menú\n1.-Suma en Decimal\n2.-Suma en hexadecimal\n3.-Suma Mixta\n4.-Salir\n"
	errorOpcion: .asciiz "\nEl valor ingresado no es una opción válida\n"
	stringOpcion1: .asciiz "\nIngrese un números enteros , o presione enter para obtener el resultado\n"
	stringOpcion3: .asciiz "\nIngrese números enteros(1234) o hexacedimales(0xfa) o presione enter para obtener el resultado\n"
	opcionError1: .asciiz "El valor ingresado no es entero.Por favor, ingrese otro valor:\n"
	opcionError3: .asciiz "El valor ingresado no es entero ni hexadecimal.Por favor, ingrese otro valor:\n"
	cadena: .space 64
	msg_1:	.asciiz "\nIngrese un número hexadecimal, o presione enter para obtener el resultado \n"
	msg_2:  .asciiz "La sumatoria de los números ingresados es: "
	msg_3:  .asciiz "\nLa suma no se puede representar en 32 bits.\n"
	newLine: .asciiz "\n"
	msg_Error_1: .asciiz "El número ingresado no es hexadecimal. Por favor, ingrese otro valor:\n"
	msg_Error_2: .asciiz "Ingrese el prefijo 0x antes del número hexadecimal.Por favor, ingrese otro valor:\n"
	overflowmsg: .asciiz "\nLa suma no se puede representar en 32 bits.\n"
	
.text
	#MUESTRA EL SALUDO	
	main: 						#etiqueta donde inicia la ejecución del programa
		la $a0,titulo 				#argumento de syscall para impresion de cadena por pantalla
		jal imprimir		
		j menu 					#salto a la etiquita Menu
							#MUESTRA EL MENÚ
	menu:
		la $a0,menuString 			#impresión del menú
		jal imprimir
		j opciones
	#CAPTURA LA OPCIÓN Y VERIFICA SI ES CORRECTA
	opciones:
		li $v0,12 				#codigo de input del sistema para leer caracter
		syscall
		add $a3,$v0,$zero 			#cargo el caracter en el registro $a3
		li $a0,'1'
		li $a1,'4'
		jal caracterEnRango
		add $t0,$v0,$zero 			#copio el resultado
		beq $zero,$t0,opcionIncorrecta		#si la opción es incorrecta muestra error
		andi $s0,$a3, 0x0F 			#convierto el valor numérico del caracter a su correspondiente número
		addi $t0,$zero,1
		addi $t1,$zero,2
		addi $t2,$zero,3								
		beq $s0,$t0,opcion1			#switch de las opciones
		beq $s0,$t1,opcion2
		beq $s0,$t2,opcion3
		j terminarPrograma			#termina la ejecución del programa
		opcionIncorrecta:
			la $a0,errorOpcion 		#imprime el mensaje de error de opción
			li $v0,4
			syscall
			j menu
	#VERIFICA SI $a3(CARACTER ACTUAL) CONTIENE UN DÍGITO DENTRO DEL RANGO DE $a0 Y $a1
	#RETORNA 1(uno) si es correcto y 0(cero) si es incorrecto
	caracterEnRango:
		slt $t0,$a3,$a0  			#Comparo si el caracter enviado es menor al valor del caracter '0'
		li $t1,1
		beq  $t0,$t1,caracterInvalido 		#si el resultado de la comparacion es menor(=1) entonces no es digito
		add $t1,$zero,$a1
		bgt $a3,$t1,caracterInvalido  		#si el resultado de la comparacion es mayor entonces no es digito
		addi $v0,$zero,1 			#retorna 1 si el digito es valido
		jr $ra
		caracterInvalido:
			addi $v0,$zero,0 		# retorna 0 si no es un digito
			jr $ra
	imprimir:
		li $v0,4 				#constante 4 que activa impresión de cadena por pantalla
		syscall
		jr $ra
	opcion1:
		addi $s0,$zero,0 			#inicializo el registro donde se almacena el resultado de la suma
		addi $v0,$zero,4
		la $a0,stringOpcion1 			#imprimo el dialogo de la opción 1
		syscall
		j loop1
	loop1:
		addi $v0,$zero,8
		la $a0,cadena				#espacio de memoria donde irá la cadena
		la $a1,cadena
		syscall
		lb $t0,0($a0)
		li $t1,'\n'
		beq $t0,$t1,MostrarResultado		#compruebo si el usuario ingreso un enter
		jal getInt				#obtengo el valor entero en caso de ser válido
		li $t1,-1
		beq $v0,$t1,wrongInput1			#si el valor ingresado no es válido muestro un mensaje de error
		add $s0,$s0,$v0
		j loop1
	wrongInput1:
		li $v0,4
		la $a0,opcionError1 			#muestro el dialogo de error si el valor ingresado no es entero
		syscall
		j loop1
			
	
	opcion2:
	# Este bloque de código: 
		# Pide un string al usuario;.
		# Calcula el número de caracteres a convertir.
		# Convierte cada caracter a su equivalente decimal (i.e 'a'=10);
		# Convierte el número hexadecimal en decimal (i.e 0xabc = 2748)
		# Suma el resultado decimal a un acumulador  (i.e 2748 + (0x1+0x1) = 2750)
		# El acumulador tiene el resultado de la suma
		# Variables:
		# $s7 es el acumulador con la respuesta
		# $s6 = (número de caracteres a convertir) - 1 (i.e 0xabc => $s6 = 2)
		# $s5 contiene la dirección base del string
		
		
	
			li $s7, 0			# $s7 es el acumulador con la respuesta.	
			la $a0, msg_1		
			li $v0,4
			syscall

		hex:	li $v0,8			# Solicita el número al usuario.
			la $a0,cadena			# Guarda el string en memoria
			li $a1,64 			# Límite de caracteres permitidos
			syscall				
																					
			add $s5, $a0, $0		# Pasa la dirección efectiva del string de $a0 a $s5
			li $a1, 0
			lb $a0, 0($s5)	
			li $t0, 10
			beq $a0, $t0, Exit_hex		# Verifica si el usuario solo presiono "enter"
			lb $a0, 1($s5)			
			li $t1, 120			# Verifica si el segundo caracter del string es "x". (Para combrobar si es hexadecimal)
			bne $a0, $t1,Err_2
			
	    		li $s6, 0			# $s6 se usará para convertir el número de hexadecimal a decimal.
	    	strlen:	add $t2, $s6, $s5		# Se itera a lo largo del string
	    		lb $t1,0($t2)
	    		addi $s6,$s6,1				
			bne $t1,$t0, strlen	
			addi $s6, $s6,-4		# Número caracteres a convertir = $s6 + 1
			
		hexSum:	add $t0, $s5, $a1		# Itero por cada caracter del string. $a1 es el iterador.
			lb $a0, 2($t0)			# Cargo el caracter del string a $a0
			li $t0, 10
			beq $a0, 10, hex		# Verifico si el caracter es un salto de linea
							
		hexVal:	li $t6,96			# Este bloque valida si los caracteres pertecen a la base hexadecimal.
			li $t7,64			# función lógica => ($a0 > 96 && $a0 <103)||($a0 > 64 && $a0 < 71)||($a0 > 47 && $a0 < 58)
			li $t8,47
			slt $t0,$t6,$a0				
			slti $t1,$a0,103	
			slt $t2,$t7,$a0
			slti $t3,$a0,71
			slt $t4,$t8,$a0
			slti $t5,$a0,58
			and  $t1,$t0,$t1 
			and  $t3,$t2,$t3 
			and  $t5,$t4,$t5 
			or $t0, $t1, $t3
			or $v0, $t0, $t5
			beq $v0,$zero,Err_1
			
		hexC_0:	li $t6,96			# Este bloque convierte $a0 a su equivalente decimal. i.e $a0='a'=97(ascii)=10(base10)
			li $t7,64
			li $t8,47
			slt $t0,$t6,$a0				
			slti $t1,$a0,103	
			and $t1,$t0,$t1 
			bne $t1, $zero, hexC_1
			slt $t2,$t7,$a0
			slti $t3,$a0,71
			and $t3,$t2,$t3 	
			bne $t3, $zero, hexC_2
			addi $a0, $a0, -48
			j Cont
		hexC_1:	addi $a0, $a0, -87
			j Cont
		hexC_2:	addi $a0, $a0, -55
			j Cont
			
		Cont: 	addi $sp, $sp, -12		# Cada valor decimal es multiplicado por 16^i. Donde i= $s6(# de caracteres)-$a1(iterador)
			sw $a1, 8($sp)	
			sw $ra, 4($sp)			
			sw $a0, 0($sp)
			sub $a1, $s6, $a1
			li $a0, 16
			jal pwr
			lw $a0, 0($sp)
			lw $ra, 4($sp)
			lw $a1, 8($sp)
			addi $sp, $sp, 8
			mult $v0,$a0			# $a0*(16^i)
			mflo $t0	
			slt $t6, $t0, $zero
			bne $t6, $zero, Err_3	
			addu $s7, $s7, $t0		# Sumo el resultado de la multiplicación con el acumulador.
			addi $a1, $a1, 1		# Incremento el iterador
			j hexSum
		
		
							# Función potencia: $a0^$a1. Es recursiva. (16,$a1)*(16,$a1-1)*...*(16,0)
		pwr:	beq $a1,$zero,end_pwr		# Caso base ($a1=0)
			addi $sp, $sp, -4
			sw $ra, 0($sp)
			addi $a1, $a1, -1
			jal pwr
			mult $v0, $a0
			mflo $v0
			lw $ra, 0($sp)
			addi $sp, $sp, 4
			jr $ra
			
		end_pwr:li $v0, 1			# resultado del caso base (16^0)= 1	
			jr $ra
		
		Err_1:	li $v0, 4			# Mensajes de Error
			la $a0, msg_Error_1		# Número no hexadecimal
			syscall
			j hex			
		
		Err_2:	li $v0, 4
			la $a0, msg_Error_2		# Prefijo 0x no aparece el número hexadecimal	
			syscall
			j hex							
		
		Err_3:	li $v0, 4			# Mensajes
			la $a0, msg_3			# Suma fuera de rango
			syscall
			j hexEnd	
		
		
	    Exit_hex:	
	    		li $v0, 4
			la $a0, msg_2			# Suma total
			syscall
					
			li $v0, 34			# Impresión del resultado total
			add $a0, $s7, $zero
			syscall		

			li $s7, 0			# Encero el acumulador con la respuesta
			
			li $v0, 4
			la $a0, newLine
			syscall			 				 	
				 			 	 			 	 			 	
	    hexEnd:	j menu
	    
		
	opcion3:
		addi $s0,$zero,0 			#inicializo el registro donde se almacena el resultado de la suma
		addi $v0,$zero,4
		la $a0,stringOpcion3 			#imprimo el dialogo de la opción 1
		syscall
		j loop3
	loop3:
		addi $v0,$zero,8
		la $a0,cadena				#espacio de memoria donde irá la cadena
		la $a1,cadena
		syscall
		lb $t0,0($a0)
		li $t1,'\n'
		beq $t0,$t1,MostrarResultado		#compruebo si el usuario usó enter para mostrar el resultado
		addi $sp,$sp,-4				#genero espacio en la pila
		sw $a0,0($sp)				#almaceno el argumento antes de ser modificado por llamada a función
		jal getHex				#obtengo el valor hexadecimal de ser posible
		lw $a0,0($sp)
		addi $sp,$sp,4
		li $t1,-1
		beq $v0,$t1,loop31			#en caso de no ser hexadecimal compruebo si es entero
		add $s0,$s0,$v0				#sumo el resultado hexadecimal enc aso de serlo
		j loop3
	loop31:
		jal getInt				#obtengo el entero de ser posible
		li $t1,-1
		beq $v0,$t1,wrongInput3			#si no es entero ni hexadecimal muestro un mensaje de error
		add $s0,$s0,$v0
		j loop3					#vuelvo a pedir que el usario ingrese un valor
	wrongInput3:
		li $v0,4
		la $a0,opcionError3 			#muestro el dialogo de error si el valor ingresado no es entero
		syscall
		j loop3
		

	
	getHex:
		addi $t0,$a0,0 				#copio la cadena en un registro temporal
		addi $t1,$zero,2 			#creo un iterador
		lb $t2,0($t0)
		lb $t3,1($t0)
		li $t4,'0'
		bne $t2,$t4,notHex
		li $t5,'x'
		sub $t5,$t5,$t3
		bne $t5,$zero,notHex
		addi $t4,$zero,0			#inicializo el registro donde se irá almacenando el número
	loopHex:
		addi $t5,$zero,1			#entero validador
		add $t1,$t1,$t0 			#recupero la direccion actual en la posicion i
		lb $a3,0($t1) 				#recupero el primer caracter
		li $t2,'\0'
		li $t3,'\n'
		beq $t2,$a3,returnHex			#si es fin de cadena devuelvo el número
		beq $t3,$a3,returnHex 			#si es un enter devuelvo el número
		addi $sp,$sp,-12 			#genero espacio en la pila	
		sw $t1,8($sp)				#guardo los registros temporales usados en caracterEnRango
		sw $t0,4($sp)
		sw $ra,0($sp)
		li $a0,'0'
		li $a1,'9'
		jal caracterEnRango
		andi $t2,$a3,0x0F			#convierto el caracter en su valor númerico
		beq $v0,$t5,loopHex2 			#verifico que el caracter este dentro del rango de dígitos permitidos
		li $a0,'a'
		li $a1,'f'
		jal caracterEnRango
		addi $t2,$a3,-87
		beq $v0,$t5,loopHex2 			#verifico que el caracter este dentro del rango de dígitos permitidos
		li $a0,'A'
		li $a1,'F'
		jal caracterEnRango
		addi $t2,$a3,-55
		beq $v0,$t5,loopHex2 			#verifico que el caracter este dentro del rango de dígitos permitidos
	loopHex2:
		lw $t1,8($sp)
		lw $t0,4($sp)
		lw $ra,0($sp)
		addi $sp,$sp,12 			#recupero espacio en la pila
		beq $zero,$v0,notHex
		sub $t1,$t1,$t0				#recupero el valor actual del iterador		
		sll $t4,$t4,4 				#multiplico por 16 el valor actual
  		add $t4,$t4,$t2				#sumo el valor del caracter actual al número anterior
		addi $t1,$t1,1 				#incremento el iterador
		j loopHex
	notHex:
		li $v0,-1
		jr $ra
	returnHex:
		addi $v0,$t4,0
		jr $ra
	getInt:
		addi $t0,$a0,0 				#copio la cadena en un registro temporal
		addi $t1,$zero,0 			#creo un iterador
		addi $t4,$zero,0
	loopInt:
		add $t1,$t1,$t0 			#recupero la direccion actual en la posicion i
		lb $a3,0($t1) 				#recupero el primer caracter
		li $t2,'\0'
		li $t3,'\n'
		beq $t2,$a3,returnInt			#si es fin de cadena devuelvo el número
		beq $t3,$a3,returnInt 			#si es un enter devuelvo el número
		addi $sp,$sp,-12 			#genero espacio en la pila	
		sw $t1,8($sp)				#guardo los registros temporales usados en caracterEnRango
		sw $t0,4($sp)
		sw $ra,0($sp)
		li $a0,'0'
		li $a1,'9'
		jal caracterEnRango			#verifico que el caracter este dentro del rango de dígitos permitidos
		andi $t2,$a3,0x0F			#convierto el caracter en su valor númerico
		lw $t1,8($sp)
		lw $t0,4($sp)
		lw $ra,0($sp)
		addi $sp,$sp,12 			#recupero espacio en la pila
		beq $zero,$v0,notInt
		sub $t1,$t1,$t0				#recupero el valor actual del iterador		
		addi $t3,$t4,0				#creo una copia del valor actual
		sll $t4,$t4,3 				#multiplico por 8 el valor actual
		add $t3,$t3,$t3 			#multiplico por dos la copia
  		add $t4,$t4,$t3				#sumo dos veces más equivalente a multiplicar por 10
  		add $t4,$t4,$t2				#sumo el valor del caracter actual al número anterior
		addi $t1,$t1,1 				#incremento el iterador
		j loopInt
	notInt:
		li $v0,-1
		jr $ra
	returnInt:
		addi $v0,$t4,0
		jr $ra
		
	MostrarResultado:
		la $a0,msg_2
		li $v0,4 				#muestro el dialogo del total de la suma entera
		syscall
		addi $a0,$s0,0				#cargo el valor total en el argumento del print
		li $v0,1 					
		syscall
		j menu 
		
	OVERFLOW:
		la $a0,overflowmsg			#cargo el mensaje de overflow
		li $v0,4 				#constante 4 que activa impresion de cadena por pantalla
		syscall
		j menu		
	terminarPrograma:
		li $v0,10 				#termina el programa
		syscall
	

.ktext 0x80000180

	la $k1,OVERFLOW
  	mtc0 $k1,$14   					#genero la nueva dirección de retorno    
  	
  	    
  	            
        eret 						#retorno de la excepción, PC <- EPC
		
	
	
