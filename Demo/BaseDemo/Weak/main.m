//
//  main.m
//  Weak
//
//  Created by Tian on 2021/5/3.
//

#import <Foundation/Foundation.h>

@interface UserModel : NSObject

@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, strong) NSString *sign;

@end


@implementation UserModel

@end


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        UserModel *user = [UserModel new];
//        user.nickName = @"xx";
        user.sign = @"hh";
        NSLog(@"Hello, World!");
    }
    return 0;
}
