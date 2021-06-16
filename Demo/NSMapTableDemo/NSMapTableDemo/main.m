//
//  main.m
//  NSMapTableDemo
//
//  Created by Tian on 2021/6/16.
//

#import <Foundation/Foundation.h>
#import "Person.h"

static NSMutableArray *arr;
static NSMutableDictionary *dict;
static NSMapTable *mapTable;

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSLog(@"Hello, World!");
        //arr = [NSMutableArray array];
        dict = [NSMutableDictionary dictionary];
        Person *p = [Person new];
        Person *p1 = [Person new];
        //[arr addObject:p];
        //[dict setObject:p forKey:p.description];
        
        
        // weak-weak
        mapTable = [NSMapTable mapTableWithKeyOptions:NSMapTableWeakMemory valueOptions:NSMapTableWeakMemory];
        [mapTable setObject:p forKey:p1];
        printf("%ld \n", mapTable.count);
    }
    NSLog(@"Game Over!");
    //arr = nil;
    dict = nil;
    return 0;
}
