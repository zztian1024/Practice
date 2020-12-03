//
//  NWRequestBody.h
//  Utility
//
//  Created by Tian on 2020/10/29.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIImage.h>
@class NWLogger;
@class NWRequestDataAttachment;

NS_ASSUME_NONNULL_BEGIN

@interface NWRequestBody : NSObject

@property (nonatomic, retain, readonly) NSData *data;

- (void)appendWithKey:(NSString *)key
            formValue:(NSString *)value
               logger:(NWLogger *)logger;

- (void)appendWithKey:(NSString *)key
           imageValue:(UIImage *)image
               logger:(NWLogger *)logger;

- (void)appendWithKey:(NSString *)key
            dataValue:(NSData *)data
               logger:(NWLogger *)logger;

- (void)appendWithKey:(NSString *)key
  dataAttachmentValue:(NWRequestDataAttachment *)dataAttachment
               logger:(NWLogger *)logger;

- (NSString *)mimeContentType;

- (NSData *)compressedData;

@end

NS_ASSUME_NONNULL_END
