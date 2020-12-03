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
    int a = 10; // pro hand -p true -s false SIGABRT
    free(a);
}

@end
