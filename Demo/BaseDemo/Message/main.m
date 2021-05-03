//
//  main.m
//  Message
//
//  Created by Tian on 2021/5/3.
//

#import <Foundation/Foundation.h>
#import "Person.h"
extern instrumentObjcMessageSends(BOOL flag);

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        instrumentObjcMessageSends(YES);
        Person *p = [Person new];
        [p playGames];
        
        [Person nationality];
    }
    return 0;
}
