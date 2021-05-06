//
//  main.m
//  Category
//
//  Created by Tian on 2021/5/5.
//

#import <Foundation/Foundation.h>
#import "Man.h"

//@interface Man (Patch)
// 
//@end
// 
//@implementation Man (Patch)
// 
//+ (void)speak:(NSString *)something {
//    NSLog(@"是谁在说话？ %@ 在说：%@",self, something);
//}
//- (void)singSong:(NSString *)song {
//    NSLog(@"是谁在唱歌？ %@ 在唱：%@",self, song);
//}
//@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        Man *man = [[Man alloc] init];
        [Man speak:@"I love you"];          // <Man: 0x100590140> 说：I love you
        [man singSong:@"I miss you"];       // 是谁在唱歌？ <Man: 0x100590140> 在唱：I miss you
        
        NSLog(@"Hello, World!");
    }
    return 0;
}
