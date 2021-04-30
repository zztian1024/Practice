//
//  main.m
//  LLDB
//
//  Created by Tian on 2021/4/25.
//

#import <Foundation/Foundation.h>

@interface Man : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger age;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) NSInteger gender;

@end
@implementation Man

@end


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        
        Man *m = [[Man alloc] init];
        NSLog(@"%@", m);
    }
    return 0;
}
