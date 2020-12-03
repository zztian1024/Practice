//
//  NWRequestDataAttachment.h
//  Utility
//
//  Created by Tian on 2020/10/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NWRequestDataAttachment : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)initWithData:(NSData *)data
                    filename:(NSString *)filename
                 contentType:(NSString *)contentType
NS_DESIGNATED_INITIALIZER;

@property (nonatomic, copy, readonly) NSString *contentType;

@property (nonatomic, strong, readonly) NSData *data;

@property (nonatomic, copy, readonly) NSString *filename;

@end

NS_ASSUME_NONNULL_END
