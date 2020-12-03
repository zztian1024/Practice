//
//  main.m
//  Property
//
//  Created by Tian on 2020/10/30.
//

#import <Foundation/Foundation.h>
#import "Setting.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        
        [Setting setAPIVersion:@"1.2.3"];
        NSLog(@"%@ - %@", [Setting name], [Setting APIVersion]);
        [Setting setJPEGCompressionQuality:@0.8];
        NSLog(@"%@", [Setting JPEGCompressionQuality]);
    }
    return 0;
}
