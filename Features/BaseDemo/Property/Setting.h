//
//  Setting.h
//  Property
//
//  Created by Tian on 2020/10/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Setting : NSObject

@property (class, nonatomic, copy, readonly) NSString *name;
@property (class, nonatomic, copy, null_resettable) NSString *APIVersion;

@end

NS_ASSUME_NONNULL_END
