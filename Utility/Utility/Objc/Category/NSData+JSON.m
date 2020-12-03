//
//  NSData+JSON.m
//  Utility
//
//  Created by Tian on 2020/10/27.
//

#import "NSData+JSON.h"
#import <zlib.h>

#define kChunkSize 1024

@implementation NSData (JSON)

+ (NSData *)dataWithJSONObject:(id)obj options:(NSJSONWritingOptions)opt error:(NSError *__autoreleasing _Nullable *)error {
    NSData *data;
    @try {
        data = [NSJSONSerialization dataWithJSONObject:obj options:opt error:error];
    } @catch (NSException *exception) {
        NSLog(@"UtilityTools - JSONSerialization - dataWithJSONObject:options:error failed: %@", exception.reason);
    }
    return data;
}

+ (id)JSONObjectWithData:(NSData *)data options:(NSJSONReadingOptions)opt error:(NSError *__autoreleasing _Nullable *)error {
    if (![data isKindOfClass:NSData.class]) {
        return nil;
    }
    
    id object;
    @try {
        object = [NSJSONSerialization JSONObjectWithData:data options:opt error:error];
    } @catch (NSException *exception) {
        NSLog(@"UtilityTools - JSONSerialization - JSONObjectWithData:options:error failed: %@", exception.reason);
    }
    return object;
}

@end


@implementation NSData (GZip)

- (NSData *)gzipData {
    const void *bytes = self.bytes;
    const NSUInteger length = self.length;
    
    if (!bytes || !length) {
        return nil;
    }
    
#if defined(__LP64__) && __LP64__
    if (length > UINT_MAX) {
        return nil;
    }
#endif
    
    // initialze stream
    z_stream stream;
    bzero(&stream, sizeof(z_stream));
    
    if (deflateInit2(&stream, -1, Z_DEFLATED, 31, 8, Z_DEFAULT_STRATEGY) != Z_OK) {
        return nil;
    }
    stream.avail_in = (uint)length;
    stream.next_in = (Bytef *)bytes;
    
    int retCode;
    NSMutableData *result = [NSMutableData dataWithCapacity:(length / 4)];
    unsigned char output[kChunkSize];
    do {
        stream.avail_out = kChunkSize;
        stream.next_out = output;
        retCode = deflate(&stream, Z_FINISH);
        if (retCode != Z_OK && retCode != Z_STREAM_END) {
            deflateEnd(&stream);
            return nil;
        }
        unsigned size = kChunkSize - stream.avail_out;
        if (size > 0) {
            [result appendBytes:output length:size];
        }
    } while (retCode == Z_OK);
    
    deflateEnd(&stream);
    
    return result;
}

@end
