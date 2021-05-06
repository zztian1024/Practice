//
//  Man+PatchB.m
//  Category
//
//  Created by Tian on 2021/5/5.
//

#import "Man+PatchB.h"

@implementation Man (PatchB)
- (void)speak:(NSString *)something
{
    NSLog(@"PatchB ==== %@ 说：%@",self, something);
}
 
- (void)singSong:(NSString *)song
{
    NSLog(@"PatchB ==== %@ 唱：%@",self, song);
}
@end
