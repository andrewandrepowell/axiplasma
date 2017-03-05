#ifndef PORT_LAYER_H_
#define PORT_LAYER_H_

#ifdef __cplusplus
extern "C" 
{
#endif
	#include "plasoc_cpu.h"
	#include "plasoc_int.h"
	#include "plasoc_uart.h"

	void initialize(void (*run)(void));
	void setbyte(unsigned byte);
	unsigned getbyte();
	void setword(unsigned word);
	unsigned getword();

#ifdef __cplusplus
}
#endif

#endif /* PORT_LAYER_H_ */
