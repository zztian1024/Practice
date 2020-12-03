//
//  NWAccessTokenCaching.h
//  Utility
//
//  Created by Tian on 2020/10/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class NWAccessToken;

@protocol NWAccessTokenCaching <NSObject>

@property (nonatomic, copy) NWAccessToken *accessToken;

- (void)clearCache;

@end

NS_ASSUME_NONNULL_END
