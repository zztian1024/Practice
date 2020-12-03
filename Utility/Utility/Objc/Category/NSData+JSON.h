//
//  NSData+JSON.h
//  Utility
//
//  Created by Tian on 2020/10/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (JSON)

+ (nullable NSData *)dataWithJSONObject:(id)obj options:(NSJSONWritingOptions)opt error:(NSError **)error;
+ (nullable id)JSONObjectWithData:(NSData *)data options:(NSJSONReadingOptions)opt error:(NSError **)error;

@end

@interface NSData (GZip)

/**
 Gzip data with default compression level if possible.
 @return nil if unable to gzip the data, otherwise gzipped data.
 */
- (nullable NSData *)gzipData;

@end

NS_ASSUME_NONNULL_END
