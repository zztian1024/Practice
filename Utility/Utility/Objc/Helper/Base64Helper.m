//
//  Base64Helper.m
//  Utility
//
//  Created by Tian on 2020/10/28.
//

#import "Base64Helper.h"

@implementation Base64Helper

#pragma mark - Class Methods

+ (NSData *)decodeAsData:(NSString *)string {
    if (!string) {
        return nil;
    }
    // This padding will be appended before stripping unknown characters, so if there are unknown characters of count % 4
    // it will not be able to decode.  Since we assume valid base64 data, we will take this as is.
    int needPadding = string.length % 4;
    if (needPadding > 0) {
        needPadding = 4 - needPadding;
        string = [string stringByPaddingToLength:string.length + needPadding withString:@"=" startingAtIndex:0];
    }
    
    return [[NSData alloc] initWithBase64EncodedString:string options:NSDataBase64DecodingIgnoreUnknownCharacters];
}

+ (NSString *)decodeAsString:(NSString *)string {
    NSData *data = [self decodeAsData:string];
    if (!data) {
        return nil;
    }
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

+ (NSString *)encodeData:(NSData *)data {
    if (!data) {
        return nil;
    }
    return [data base64EncodedStringWithOptions:0];
}

+ (NSString *)encodeString:(NSString *)string {
    return [Base64Helper encodeData:[string dataUsingEncoding:NSUTF8StringEncoding]];
}

@end
