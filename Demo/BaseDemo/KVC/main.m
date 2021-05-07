//
//  main.m
//  KVC
//
//  Created by Tian on 2020/10/18.
//

#import <Foundation/Foundation.h>
#import "Person.h"

/// KVC 键值编码
/// [item setValue:@"value" forKey:@"key"];
/// 1.首先去模型中查找有没有setKey,如果找到，直接调用赋值：self setKey:@"value"
/// 2.去模型中查找有没有key属性，如果有，直接赋值key= value
/// 3.去模块中查找有没有_key 属性，如果有，直接访问属性 _key = value
/// 4.找不到，报错， setValue: forUndefinedKey:。
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        Person *p = [Person new];
        p.name = @"ABC";
        p.toy = [Toy new];
        p->_age = 20;
        // KVC 赋值
        [p setValue:@"xiaoming" forKey:@"name"];
        [p setValue:@"3000" forKey:@"_salary"]; // 自动类型转换
        [p setValue:@(10000) forKeyPath:@"_money"]; // 修改私有成员变量
        [p setValue:@"Deer" forKeyPath:@"toy.name"]; // forKeyPath 包含所有 foryKey 功能
        
        [p print]; // xiaoming 10000 3000

        
        Person *p1 = [Person new];
        [p1 setValue:@"xiaowang" forKey:@"name"];
        
        Person *p2 = [Person new];
        [p2 setValue:@"xiaoli" forKey:@"name"];
        
        Person *p3 = [Person new];
        [p3 setValue:@"xiaoliu" forKey:@"name"];
        
        NSArray *persons = @[p, p1, p2, p3];
        NSArray *names = [persons valueForKey:@"name"];
        NSLog(@"%@", names);
        
        // 如果没有 key， 则会执行setValue: forUndefinedKey:
        // 如果没实现这个方法，则会造成 crash.
        [p3 setValue:@"value" forKey:@"someKey"];
    }
    return 0;
}
