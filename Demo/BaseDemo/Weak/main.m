//
//  main.m
//  weak
//
//  Created by Tian on 2021/5/6.
//

#import <Foundation/Foundation.h>
#import "UserModel.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        UserModel *user = [UserModel new];
        NSLog(@"%@", user);
        id __weak obj = user;
        NSLog(@"Hello, World!");
    }
    return 0;
}
