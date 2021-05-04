//
//  main.m
//  Dyld
//
//  Created by Tian on 2021/5/4.
//

#import <Foundation/Foundation.h>

@interface Person : NSObject

@end

@implementation Person

+ (void)load {
    printf("----------load-----------: %s\n", __func__);
}

@end

__attribute__((constructor)) void cc_func () {
    printf("--------cc_func----------: %s\n", __func__);
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
    }
    return 0;
}
