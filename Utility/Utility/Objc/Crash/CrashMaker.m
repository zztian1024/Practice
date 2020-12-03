//
//  CrashMaker.m
//  Utility
//
//  Created by Tian on 2020/10/29.
//

#import "CrashMaker.h"

@implementation CrashMaker

+ (void)outOfBounds {
    @[][0];
}

+ (void)signalCrash {
    int a = 10; // pro hand -p true -s false SIGABRT
    free(a);
}

@end
