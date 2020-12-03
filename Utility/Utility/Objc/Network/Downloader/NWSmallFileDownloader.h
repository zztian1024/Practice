//
//  NWFileDownload.h
//  Utility
//
//  Created by Tian on 2020/10/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NWSmallFileDownloader : NSObject

+ (void)downloadWithURLs:(NSArray *)urls
               filePaths:(nullable NSArray *)filePaths
              completion:(void(^)(void))completion;

@end

NS_ASSUME_NONNULL_END
