//
//  CrashMaker.m
//  CrashSupervisor
//
//  Created by Tian on 2020/9/19.
//

#import "CrashMaker.h"
#import <sys/mman.h>
#import <mach/mach.h>

@implementation CrashMaker

+ (void)outOfBounds {
    @[][0];
}

+ (void)signalCrash {
    void *signal = malloc(1024);
    free(signal);
    free(signal);
}

@end
