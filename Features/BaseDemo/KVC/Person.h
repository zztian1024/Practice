//
//  Person.h
//  KVCDemo
//
//  Created by Tian on 2020/10/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Toy : NSObject

@property (nonatomic, copy) NSString *name;

@end

@interface Person : NSObject {
    @public
    int _age;
}

@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) Toy *toy;

- (void)print;
@end

NS_ASSUME_NONNULL_END
