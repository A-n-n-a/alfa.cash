#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "DekuSanCore.h"
#import "DekuSanCrypto.h"

FOUNDATION_EXPORT double DekuSanCoreVersionNumber;
FOUNDATION_EXPORT const unsigned char DekuSanCoreVersionString[];

