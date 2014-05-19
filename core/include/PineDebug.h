/*
 * PineDebug.h
 *
 *  Created on: May 19, 2014
 *      Author: lxb
 */

#ifndef _PineDebug_H_
#define _PineDebug_H_

#if (PINEDEBUG==1)
/**
 * A flag that enables/disables the debug mode
 */
#define PINEDBG
#else // PINEDEBUG
#undef  PINEDBG
#endif // PINEDEBUG

#ifdef  PINEDBG
#include <stdio.h>
#include <execinfo.h>

/**
 * Debugging macro that prints in the standard output
 * when debug mode is enabled (PINEDBG == 1)
 */
#define PinePrint(S...) \
    do { printf(S); fflush(stdout); }while(0)

/**
 * Debugging macro that asserts and prints the line number and filename
 * containing the failed condition when debug mode is enabled 
 * (PINEDBG == 1) 
 */
#define PineAssert(x) \
    { \
        if ((x) == 0) \
        { \
            printf("---ASSERT--- at line %d in %s!\n", __LINE__, __FILE__); \
            fflush(stdout); \
            while (1) \
                { \
                usleep(100 * 1000 * 1000); \
                } \
        } \
    }

/**
 * Debugging macro that prints the filename, function name, and line number
 * in the standard output when debug mode is enabled (PINEDBG ==
 * 1) 
 */
#define PinePrint_Pos(S...) \
    { \
        printf("[pine] %s : Line[%u], [%s]\n", \
            __FILE__, \
            __LINE__, \
            __FUNCTION__); \
            printf(## S); \
    }



#else // PINEDBG

/**
 * Debugging macro that prints in the standard output when debug mode is
 * enabled (PINEDBG == 1)
 */
#define PinePrint(S...)

/**
 * Debugging macro that asserts and prints the line number and filename
 * containing the failed condition when debug mode is enabled (WDBG == 1)
 */
#define PineAssert(x)

/**
 * Debugging macro that prints the filename, function name, and line number
 * in the standard output when debug mode is enabled (WDBG == 1)
 */
#define PinePrint_Pos(S...)
#endif //PINEDBG


#endif /* _PineDebug_H_ */

