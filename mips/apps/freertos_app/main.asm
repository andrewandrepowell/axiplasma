	.file	1 "main.c"
	.section .mdebug.abi32
	.previous
	.nan	legacy
	.module	fp=32
	.module	nooddspreg
	.text
	.align	2
	.globl	FreeRTOS_TickISR
	.set	nomips16
	.set	nomicromips
	.ent	FreeRTOS_TickISR
	.type	FreeRTOS_TickISR, @function
FreeRTOS_TickISR:
	.frame	$sp,24,$31		# vars= 0, regs= 1/0, args= 16, gp= 0
	.mask	0x80000000,-4
	.fmask	0x00000000,0
	addiu	$sp,$sp,-24
	sw	$31,20($sp)
	jal	xTaskIncrementTick
	.set	noreorder
	.set	nomacro
	beq	$2,$0,$L2
	li	$2,1			# 0x1
	.set	macro
	.set	reorder

	sw	$2,%gp_rel(FreeRTOS_Yield)($28)
$L2:
	lw	$31,20($sp)
	lw	$2,%gp_rel(timer_obj)($28)
	li	$3,7			# 0x7
	sw	$3,0($2)
	.set	noreorder
	.set	nomacro
	jr	$31
	addiu	$sp,$sp,24
	.set	macro
	.set	reorder

	.end	FreeRTOS_TickISR
	.size	FreeRTOS_TickISR, .-FreeRTOS_TickISR
	.align	2
	.globl	gpio_isr
	.set	nomips16
	.set	nomicromips
	.ent	gpio_isr
	.type	gpio_isr, @function
gpio_isr:
	.frame	$sp,32,$31		# vars= 8, regs= 1/0, args= 16, gp= 0
	.mask	0x80000000,-4
	.fmask	0x00000000,0
	addiu	$sp,$sp,-32
	sw	$31,28($sp)
	sw	$0,16($sp)
	lw	$2,%gp_rel(gpio_obj)($28)
	li	$3,3			# 0x3
	lw	$4,%gp_rel(task_input_obj)($28)
	sw	$3,0($2)
	.set	noreorder
	.set	nomacro
	jal	vTaskNotifyGiveFromISR
	addiu	$5,$sp,16
	.set	macro
	.set	reorder

	lw	$2,16($sp)
	#nop
	.set	noreorder
	.set	nomacro
	beq	$2,$0,$L7
	li	$2,1			# 0x1
	.set	macro
	.set	reorder

	sw	$2,%gp_rel(FreeRTOS_Yield)($28)
$L7:
	lw	$31,28($sp)
	#nop
	.set	noreorder
	.set	nomacro
	jr	$31
	addiu	$sp,$sp,32
	.set	macro
	.set	reorder

	.end	gpio_isr
	.size	gpio_isr, .-gpio_isr
	.align	2
	.globl	task_input_code
	.set	nomips16
	.set	nomicromips
	.ent	task_input_code
	.type	task_input_code, @function
task_input_code:
	.frame	$sp,32,$31		# vars= 8, regs= 1/0, args= 16, gp= 0
	.mask	0x80000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-32
	sw	$31,28($sp)
	li	$5,-1			# 0xffffffffffffffff
$L16:
	jal	ulTaskNotifyTake
	li	$4,1			# 0x1

	lw	$2,%gp_rel(gpio_obj)($28)
	lw	$4,%gp_rel(queue_input_obj)($28)
	lw	$2,8($2)
	move	$7,$0
	li	$6,-1			# 0xffffffffffffffff
	addiu	$5,$sp,16
	jal	xQueueGenericSend
	sw	$2,16($sp)

	b	$L16
	li	$5,-1			# 0xffffffffffffffff

	.set	macro
	.set	reorder
	.end	task_input_code
	.size	task_input_code, .-task_input_code
	.align	2
	.globl	task_time_code
	.set	nomips16
	.set	nomicromips
	.ent	task_time_code
	.type	task_time_code, @function
task_time_code:
	.frame	$sp,32,$31		# vars= 8, regs= 1/0, args= 16, gp= 0
	.mask	0x80000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-32
	sw	$31,28($sp)
	jal	xTaskGetTickCount
	nop

	sw	$2,16($sp)
	addiu	$4,$sp,16
$L20:
	jal	vTaskDelayUntil
	li	$5,4			# 0x4

	lw	$4,%gp_rel(sem_time_obj)($28)
	move	$7,$0
	move	$6,$0
	jal	xQueueGenericSend
	move	$5,$0

	b	$L20
	addiu	$4,$sp,16

	.set	macro
	.set	reorder
	.end	task_time_code
	.size	task_time_code, .-task_time_code
	.align	2
	.globl	task_main_code
	.set	nomips16
	.set	nomicromips
	.ent	task_main_code
	.type	task_main_code, @function
task_main_code:
	.frame	$sp,48,$31		# vars= 8, regs= 5/0, args= 16, gp= 0
	.mask	0x800f0000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-48
	sw	$17,32($sp)
	lui	$17,%hi(ticks_ary)
	sw	$19,40($sp)
	sw	$18,36($sp)
	sw	$16,28($sp)
	sw	$31,44($sp)
	move	$16,$0
	move	$19,$0
	li	$18,1			# 0x1
	addiu	$17,$17,%lo(ticks_ary)
$L31:
	lw	$4,%gp_rel(queue_input_obj)($28)
	move	$7,$0
	move	$6,$0
	jal	xQueueGenericReceive
	addiu	$5,$sp,16

	bne	$2,$18,$L22
	move	$2,$0

	lw	$19,16($sp)
	nop
	nor	$5,$0,$19
	li	$4,16			# 0x10
	sll	$3,$18,$2
$L39:
	and	$3,$3,$5
	beq	$3,$0,$L23
	sll	$3,$2,2

	addu	$3,$3,$17
	sw	$0,0($3)
$L23:
	addiu	$2,$2,1
	bne	$2,$4,$L39
	sll	$3,$18,$2

$L22:
	lw	$4,%gp_rel(sem_time_obj)($28)
	move	$7,$0
	move	$6,$0
	jal	xQueueGenericReceive
	move	$5,$0

	bne	$2,$18,$L31
	move	$4,$0

	li	$6,24			# 0x18
	li	$5,16			# 0x10
	sll	$2,$18,$4
$L40:
	and	$3,$19,$2
	beq	$3,$0,$L26
	sll	$3,$4,2

	addu	$3,$3,$17
	lw	$7,0($3)
	nop
	bne	$7,$6,$L27
	nop

	sw	$0,0($3)
	and	$3,$2,$16
	beq	$3,$0,$L28
	nop

$L26:
	nor	$2,$0,$2
	b	$L29
	and	$16,$16,$2

$L28:
	or	$16,$16,$2
$L29:
	addiu	$4,$4,1
$L38:
	bne	$4,$5,$L40
	sll	$2,$18,$4

	lw	$2,%gp_rel(gpio_obj)($28)
	nop
	sw	$16,8($2)
	b	$L31
	nop

$L27:
	lw	$2,0($3)
	nop
	addiu	$2,$2,1
	sw	$2,0($3)
	b	$L38
	addiu	$4,$4,1

	.set	macro
	.set	reorder
	.end	task_main_code
	.size	task_main_code, .-task_main_code
	.align	2
	.globl	FreeRTOS_UserISR
	.set	nomips16
	.set	nomicromips
	.ent	FreeRTOS_UserISR
	.type	FreeRTOS_UserISR, @function
FreeRTOS_UserISR:
	.frame	$sp,32,$31		# vars= 0, regs= 3/0, args= 16, gp= 0
	.mask	0x80030000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	lui	$3,%hi(int_obj)
	lw	$2,%lo(int_obj)($3)
	addiu	$sp,$sp,-32
	lw	$2,4($2)
	sw	$17,24($sp)
	lui	$17,%hi(int_obj+4)
	sw	$16,20($sp)
	sw	$31,28($sp)
	move	$16,$3
	addiu	$17,$17,%lo(int_obj+4)
	sltu	$3,$2,8
$L49:
	bne	$3,$0,$L43
	sll	$2,$2,3

	lw	$2,%gp_rel(FreeRTOS_Yield)($28)
	nop
	beq	$2,$0,$L41
	nop

	lw	$2,%gp_rel(gpio_obj)($28)
	lw	$3,%gp_rel(pxCurrentTCB)($28)
	nop
	sw	$3,8($2)
	sw	$0,%gp_rel(FreeRTOS_Yield)($28)
	jal	vTaskSwitchContext
	nop

	lw	$2,%gp_rel(gpio_obj)($28)
	lw	$3,%gp_rel(pxCurrentTCB)($28)
	nop
	sw	$3,8($2)
$L41:
	lw	$31,28($sp)
	lw	$17,24($sp)
	lw	$16,20($sp)
	jr	$31
	addiu	$sp,$sp,32

$L43:
	addu	$2,$17,$2
	lw	$3,0($2)
	lw	$4,4($2)
	jalr	$3
	nop

	lw	$2,%lo(int_obj)($16)
	nop
	lw	$2,4($2)
	b	$L49
	sltu	$3,$2,8

	.set	macro
	.set	reorder
	.end	FreeRTOS_UserISR
	.size	FreeRTOS_UserISR, .-FreeRTOS_UserISR
	.align	2
	.globl	FreeRTOS_EnableInterrupts
	.set	nomips16
	.set	nomicromips
	.ent	FreeRTOS_EnableInterrupts
	.type	FreeRTOS_EnableInterrupts, @function
FreeRTOS_EnableInterrupts:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	lui	$2,%hi(int_obj)
	lw	$2,%lo(int_obj)($2)
	li	$3,255			# 0xff
	sw	$3,0($2)
	jr	$31
	.end	FreeRTOS_EnableInterrupts
	.size	FreeRTOS_EnableInterrupts, .-FreeRTOS_EnableInterrupts
	.align	2
	.globl	FreeRTOS_DisableInterrupts
	.set	nomips16
	.set	nomicromips
	.ent	FreeRTOS_DisableInterrupts
	.type	FreeRTOS_DisableInterrupts, @function
FreeRTOS_DisableInterrupts:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	lui	$2,%hi(int_obj)
	lw	$2,%lo(int_obj)($2)
	#nop
	sw	$0,0($2)
	jr	$31
	.end	FreeRTOS_DisableInterrupts
	.size	FreeRTOS_DisableInterrupts, .-FreeRTOS_DisableInterrupts
	.align	2
	.globl	vAssertCalled
	.set	nomips16
	.set	nomicromips
	.ent	vAssertCalled
	.type	vAssertCalled, @function
vAssertCalled:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	lw	$2,%gp_rel(gpio_obj)($28)
	nop
	sw	$5,8($2)
$L53:
	b	$L53
	nop

	.set	macro
	.set	reorder
	.end	vAssertCalled
	.size	vAssertCalled, .-vAssertCalled
	.section	.rodata.str1.4,"aMS",@progbits,1
	.align	2
$LC0:
	.ascii	"main\000"
	.align	2
$LC1:
	.ascii	"input\000"
	.align	2
$LC2:
	.ascii	"time\000"
	.section	.text.startup,"ax",@progbits
	.align	2
	.globl	main
	.set	nomips16
	.set	nomicromips
	.ent	main
	.type	main, @function
main:
	.frame	$sp,48,$31		# vars= 0, regs= 5/0, args= 24, gp= 0
	.mask	0x800f0000,-4
	.fmask	0x00000000,0
	addiu	$sp,$sp,-48
	move	$4,$0
	sw	$16,28($sp)
	sw	$31,44($sp)
	sw	$19,40($sp)
	sw	$18,36($sp)
	sw	$17,32($sp)
	.set	noreorder
	.set	nomacro
	jal	OS_AsmInterruptEnable
	lui	$16,%hi(int_obj)
	.set	macro
	.set	reorder

	li	$2,1151336448			# 0x44a00000
	sw	$2,%lo(int_obj)($16)
	lui	$3,%hi(int_obj+68)
	lui	$2,%hi(int_obj+4)
	addiu	$2,$2,%lo(int_obj+4)
	addiu	$3,$3,%lo(int_obj+68)
$L55:
	addiu	$2,$2,8
	.set	noreorder
	.set	nomacro
	bne	$2,$3,$L55
	sw	$0,-8($2)
	.set	macro
	.set	reorder

	li	$2,1151467520			# 0x44a20000
	lui	$3,%hi(gpio_isr)
	sw	$2,%gp_rel(gpio_obj)($28)
	addiu	$3,$3,%lo(gpio_isr)
	addiu	$2,$16,%lo(int_obj)
	sw	$3,12($2)
	li	$4,10000			# 0x2710
	li	$3,1151401984			# 0x44a10000
	sw	$3,%gp_rel(timer_obj)($28)
	sw	$0,16($2)
	sw	$4,4($3)
	lui	$3,%hi(FreeRTOS_TickISR)
	addiu	$3,$3,%lo(FreeRTOS_TickISR)
	lui	$4,%hi(ticks_ary)
	sw	$3,4($2)
	li	$6,64			# 0x40
	move	$5,$0
	addiu	$4,$4,%lo(ticks_ary)
	.set	noreorder
	.set	nomacro
	jal	memset
	sw	$0,8($2)
	.set	macro
	.set	reorder

	move	$6,$0
	li	$5,4			# 0x4
	.set	noreorder
	.set	nomacro
	jal	xQueueGenericCreate
	li	$4,8			# 0x8
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	bne	$2,$0,$L56
	sw	$2,%gp_rel(queue_input_obj)($28)
	.set	macro
	.set	reorder

	lw	$2,%gp_rel(gpio_obj)($28)
	li	$3,177			# 0xb1
	sw	$3,8($2)
$L57:
	b	$L57
$L56:
	move	$5,$0
	.set	noreorder
	.set	nomacro
	jal	xQueueCreateCountingSemaphore
	li	$4,8			# 0x8
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	bne	$2,$0,$L58
	sw	$2,%gp_rel(sem_time_obj)($28)
	.set	macro
	.set	reorder

	lw	$2,%gp_rel(gpio_obj)($28)
	li	$3,179			# 0xb3
	sw	$3,8($2)
$L59:
	b	$L59
$L58:
	li	$17,3			# 0x3
	lui	$5,%hi($LC0)
	lui	$4,%hi(task_main_code)
	sw	$0,20($sp)
	sw	$17,16($sp)
	move	$7,$0
	li	$6,256			# 0x100
	addiu	$5,$5,%lo($LC0)
	.set	noreorder
	.set	nomacro
	jal	xTaskCreate
	addiu	$4,$4,%lo(task_main_code)
	.set	macro
	.set	reorder

	move	$19,$2
	li	$2,1			# 0x1
	.set	noreorder
	.set	nomacro
	beq	$19,$2,$L60
	li	$3,181			# 0xb5
	.set	macro
	.set	reorder

	lw	$2,%gp_rel(gpio_obj)($28)
	#nop
	sw	$3,8($2)
$L61:
	b	$L61
$L60:
	addiu	$2,$28,%gp_rel(task_input_obj)
	lui	$5,%hi($LC1)
	lui	$4,%hi(task_input_code)
	sw	$2,20($sp)
	sw	$17,16($sp)
	move	$7,$0
	li	$6,256			# 0x100
	addiu	$5,$5,%lo($LC1)
	.set	noreorder
	.set	nomacro
	jal	xTaskCreate
	addiu	$4,$4,%lo(task_input_code)
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	beq	$2,$19,$L62
	move	$18,$2
	.set	macro
	.set	reorder

	lw	$2,%gp_rel(gpio_obj)($28)
	li	$3,183			# 0xb7
	sw	$3,8($2)
$L63:
	b	$L63
$L62:
	lui	$5,%hi($LC2)
	lui	$4,%hi(task_time_code)
	sw	$0,20($sp)
	sw	$17,16($sp)
	move	$7,$0
	li	$6,256			# 0x100
	addiu	$5,$5,%lo($LC2)
	.set	noreorder
	.set	nomacro
	jal	xTaskCreate
	addiu	$4,$4,%lo(task_time_code)
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	beq	$2,$18,$L64
	li	$3,185			# 0xb9
	.set	macro
	.set	reorder

	lw	$2,%gp_rel(gpio_obj)($28)
	#nop
	sw	$3,8($2)
$L65:
	b	$L65
$L64:
	lw	$3,%lo(int_obj)($16)
	li	$4,255			# 0xff
	sw	$4,0($3)
	lw	$3,%gp_rel(timer_obj)($28)
	#nop
	sw	$17,0($3)
	lw	$3,%gp_rel(gpio_obj)($28)
	#nop
	sw	$2,0($3)
	jal	vTaskStartScheduler
	lw	$2,%gp_rel(gpio_obj)($28)
	li	$3,197			# 0xc5
	sw	$3,8($2)
$L66:
	b	$L66
	.end	main
	.size	main, .-main

	.comm	ticks_ary,64,4

	.comm	task_input_obj,4,4

	.comm	sem_time_obj,4,4

	.comm	queue_input_obj,4,4

	.comm	gpio_obj,4,4

	.comm	timer_obj,4,4

	.comm	int_obj,68,4
	.ident	"GCC: (GNU) 6.3.0"
