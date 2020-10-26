//
//  main.m
//  KVO
//
//  Created by Tian on 2020/10/18.
//

#import <Foundation/Foundation.h>
#import "TestClass.h"

/// KVO : Key Value Observing (键值监听)
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        TestClass *t = [TestClass new];
        [t test];
    }
    return 0;
}
