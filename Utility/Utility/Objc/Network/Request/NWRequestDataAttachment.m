//
//  NWRequestDataAttachment.m
//  Utility
//
//  Created by Tian on 2020/10/29.
//

#import "NWRequestDataAttachment.h"

@implementation NWRequestDataAttachment

- (instancetype)initWithData:(NSData *)data filename:(NSString *)filename contentType:(NSString *)contentType
{
    if ((self = [super init])) {
        _data = data;
        _filename = [filename copy];
        _contentType = [contentType copy];
    }
    return self;
}

@end
