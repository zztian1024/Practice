//
//  NWRequestBody.m
//  Utility
//
//  Created by Tian on 2020/10/29.
//

#import "NWRequestBody.h"
#import "UtilityTools.h"
#import "NWSettings.h"
#import "NSMutableDictionary+Safe.h"
#import "NSMutableArray+Safe.h"
#import "NWLogger.h"
#import "NWRequestDataAttachment.h"
#import "NWConstants.h"

#define kNewline @"\r\n"

@implementation NWRequestBody
{
  NSMutableData *_data;
  NSMutableDictionary *_json;
  NSString *_stringBoundary;
}

- (instancetype)init
{
  if ((self = [super init])) {
      _stringBoundary =  @"-----boundary-----";//[FBSDKCrypto randomString:32];
    _data = [[NSMutableData alloc] init];
    _json = [NSMutableDictionary dictionary];
  }

  return self;
}

- (NSString *)mimeContentType
{
  if (_json) {
    return @"application/json";
  } else {
    return [NSString stringWithFormat:@"multipart/form-data; boundary=%@", _stringBoundary];
  }
}

- (void)appendUTF8:(NSString *)utf8
{
  if (!_data.length) {
    NSString *headerUTF8 = [NSString stringWithFormat:@"--%@%@", _stringBoundary, kNewline];
    NSData *headerData = [headerUTF8 dataUsingEncoding:NSUTF8StringEncoding];
    [_data appendData:headerData];
  }
  NSData *data = [utf8 dataUsingEncoding:NSUTF8StringEncoding];
  [_data appendData:data];
}

- (void)appendWithKey:(NSString *)key
            formValue:(NSString *)value
               logger:(NWLogger *)logger
{
  [self _appendWithKey:key filename:nil contentType:nil contentBlock:^{
    [self appendUTF8:value];
  }];
  if (key && value) {
    [_json safe_setObject:value forKey:key];
  }
  [logger appendFormat:@"\n    %@:\t%@", key, (NSString *)value];
}

- (void)appendWithKey:(NSString *)key
           imageValue:(UIImage *)image
               logger:(NWLogger *)logger
{
  NSData *data = UIImageJPEGRepresentation(image, [NWSettings JPEGCompressionQuality]);
  [self _appendWithKey:key filename:key contentType:@"image/jpeg" contentBlock:^{
    [self->_data appendData:data];
  }];
  _json = nil;
  [logger appendFormat:@"\n    %@:\t<Image - %lu kB>", key, (unsigned long)(data.length / 1024)];
}

- (void)appendWithKey:(NSString *)key
            dataValue:(NSData *)data
               logger:(NWLogger *)logger
{
  [self _appendWithKey:key filename:key contentType:@"content/unknown" contentBlock:^{
    [self->_data appendData:data];
  }];
  _json = nil;
  [logger appendFormat:@"\n    %@:\t<Data - %lu kB>", key, (unsigned long)(data.length / 1024)];
}

- (void)appendWithKey:(NSString *)key
  dataAttachmentValue:(NWRequestDataAttachment *)dataAttachment
               logger:(NWLogger *)logger
{
  NSString *filename = dataAttachment.filename ?: key;
  NSString *contentType = dataAttachment.contentType ?: @"content/unknown";
  NSData *data = dataAttachment.data;
  [self _appendWithKey:key filename:filename contentType:contentType contentBlock:^{
    [self->_data appendData:data];
  }];
  _json = nil;
  [logger appendFormat:@"\n    %@:\t<Data - %lu kB>", key, (unsigned long)(data.length / 1024)];
}

- (NSData *)data
{
  if (_json) {
    NSData *jsonData;
    if (_json.allKeys.count > 0) {
      jsonData = [UtilityTools dataWithJSONObject:_json options:0 error:nil];
    } else {
      jsonData = [NSData data];
    }

    return jsonData;
  }
  return [_data copy];
}

- (void)_appendWithKey:(NSString *)key
              filename:(NSString *)filename
           contentType:(NSString *)contentType
          contentBlock:(NWCodeBlock)contentBlock
{
  NSMutableArray *disposition = [[NSMutableArray alloc] init];
  [disposition safe_addObject:@"Content-Disposition: form-data"];
  if (key) {
    [disposition safe_addObject:[[NSString alloc] initWithFormat:@"name=\"%@\"", key]];
  }
  if (filename) {
    [disposition safe_addObject:[[NSString alloc] initWithFormat:@"filename=\"%@\"", filename]];
  }
  [self appendUTF8:[[NSString alloc] initWithFormat:@"%@%@", [disposition componentsJoinedByString:@"; "], kNewline]];
  if (contentType) {
    [self appendUTF8:[[NSString alloc] initWithFormat:@"Content-Type: %@%@", contentType, kNewline]];
  }
  [self appendUTF8:kNewline];
  if (contentBlock != NULL) {
    contentBlock();
  }
  [self appendUTF8:[[NSString alloc] initWithFormat:@"%@--%@%@", kNewline, _stringBoundary, kNewline]];
}

- (NSData *)compressedData
{
  if (!self.data.length || ![[self mimeContentType] isEqualToString:@"application/json"]) {
    return nil;
  }

  return [UtilityTools gzip:self.data];
}
@end
