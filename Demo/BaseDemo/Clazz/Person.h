//
//  Person.h
//  Clazz
//
//  Created by Tian on 2021/5/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Person : NSObject

@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *hobby;

- (void)sayHello;

@end

NS_ASSUME_NONNULL_END
