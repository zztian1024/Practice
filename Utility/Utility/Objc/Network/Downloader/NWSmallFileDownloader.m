//
//  NWFileDownload.m
//  Utility
//
//  Created by Tian on 2020/10/30.
//

#import "NWSmallFileDownloader.h"
#import "NSMutableArray+Safe.h"

#define FILE_DOWNLOAD_PATH @"file-cache"

static NSString *_directoryPath;
typedef void(^DownloadFinishedBlock)(BOOL success, NSString *filePath, NSString *urlString);

@implementation NWSmallFileDownloader

+ (NSString *)randomFilePathWithSuffixing:(NSString *)suffixing {
    if (!_directoryPath) {
        NSString *dirPath = [NSTemporaryDirectory() stringByAppendingPathComponent:FILE_DOWNLOAD_PATH];
        if (![[NSFileManager defaultManager] fileExistsAtPath:dirPath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:NULL error:NULL];
        }
        _directoryPath = dirPath;
    }
    return [_directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@", [NSUUID UUID].UUIDString, suffixing]];
}

+ (void)downloadWithURLs:(NSArray *)urls filePaths:(NSArray *)filePaths completion:(void(^)(void))completion {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    
    for (int i = 0; i < urls.count; i++) {
        NSString *urlString = [urls safe_objectAtIndex:i];
        NSString *filePath = [filePaths safe_objectAtIndex:i];
        if (!filePath) {
            filePath = [self randomFilePathWithSuffixing:@""];
        }
        [self download:urlString
              filePath:filePath
                 queue:queue
                 group:group
            completion:^(BOOL success, NSString *filePath, NSString *urlString) {
            NSLog(@" fileIndex: %d, download:%@", i, success ? @"success" : @"failed");
            NSLog(@" filePath: %@ \nurlString:%@", filePath, urlString);
        }];
    }
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (completion) {
            completion();
        }
    });
}

+ (void)download:(NSString *)urlString
        filePath:(NSString *)filePath
        queue:(dispatch_queue_t)queue
        group:(dispatch_group_t)group
        completion:(DownloadFinishedBlock)finished {
    if (!filePath || [[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return;
    }
    dispatch_group_async(group,
                         queue, ^{
        NSURL *url = [NSURL URLWithString:urlString];
        NSData *urlData = [NSData dataWithContentsOfURL:url];
        if (urlData) {
            BOOL res = [urlData writeToFile:filePath atomically:YES];
            if (finished) {
                finished(res, filePath, urlString);
            }
        }
    });
}

@end
