//
//  LibAnalyzer.h
//  Utility
//
//  Created by Tian on 2020/10/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LibAnalyzer : NSObject

+ (NSDictionary<NSString *, NSString *> *)getMethodsTable:(NSArray<NSString *> *)prefixes
                                               frameworks:(NSArray<NSString *> *_Nullable)frameworks;
+ (nullable NSArray<NSString *> *)symbolicateCallstack:(NSArray<NSString *> *)callstack
                                         methodMapping:(NSDictionary<NSString *, id> *)methodMapping;

@end

NS_ASSUME_NONNULL_END
