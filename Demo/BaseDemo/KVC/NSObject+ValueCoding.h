//
//  NSObject+ValueCoding.h
//  KVC
//
//  Created by Tian on 2021/5/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (ValueCoding)

- (void)zy_setValue:(nullable id)value forKey:(NSString *)key;
- (nullable id)zy_valueForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
