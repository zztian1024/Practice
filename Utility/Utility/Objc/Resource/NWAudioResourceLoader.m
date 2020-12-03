//
//  NWResourceLoader.m
//  Utility
//
//  Created by Tian on 2020/11/1.
//

#import "NWAudioResourceLoader.h"
#import "TargetConditionals.h"
#import <AudioToolbox/AudioToolbox.h>

@implementation NWAudioResourceLoader {
    NSFileManager *_fileManager;
    NSURL *_fileURL;
    SystemSoundID _systemSoundID;
}

#pragma mark - Class Methods

+ (instancetype)sharedLoader {
    static NSMutableDictionary *_loaderCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _loaderCache = [[NSMutableDictionary alloc] init];
    });
    
    NSString *name = [self name];
    NWAudioResourceLoader *loader;
    @synchronized(_loaderCache) {
        loader = _loaderCache[name];
        if (!loader) {
            loader = [[self alloc] init];
            NSError *error = nil;
            if ([loader loadSound:&error]) {
                //[FBSDKTypeUtility dictionary:_loaderCache setObject:loader forKey:name];
            } else {
                // error
            }
        }
    }
    
    return loader;
}

#pragma mark - Object Lifecycle

- (instancetype)init {
    if ((self = [super init])) {
        _fileManager = [[NSFileManager alloc] init];
    }
    return self;
}

- (void)dealloc {
    //fbsdkdfl_AudioServicesDisposeSystemSoundID(_systemSoundID);
}

#pragma mark - Public API

- (BOOL)loadSound:(NSError **)errorRef {
    NSURL *fileURL = [self _fileURL:errorRef];
    
    if (![_fileManager fileExistsAtPath:fileURL.path]) {
        NSData *data = [[self class] data];
        if (![data writeToURL:fileURL options:NSDataWritingAtomic error:errorRef]) {
            return NO;
        }
    }
    // err
    OSStatus status = kAudioServicesNoError;// fbsdkdfl_AudioServicesCreateSystemSoundID((__bridge CFURLRef)fileURL, &_systemSoundID);
    return (status == kAudioServicesNoError);
}

- (void)playSound {
    if ((_systemSoundID == 0) && ![self loadSound:NULL]) {
        return;
    }
    //fbsdkdfl_AudioServicesPlaySystemSound(_systemSoundID);
}

#pragma mark - Helper Methods

- (NSURL *)_fileURL:(NSError **)errorRef {
    if (_fileURL) {
        return _fileURL;
    }
    
    NSURL *baseURL = [_fileManager URLForDirectory:NSCachesDirectory
                                          inDomain:NSUserDomainMask
                                 appropriateForURL:nil
                                            create:YES
                                             error:errorRef];
    if (!baseURL) {
        return nil;
    }
    
    NSURL *directoryURL = [baseURL URLByAppendingPathComponent:@"fb_audio" isDirectory:YES];
    NSURL *versionURL = [directoryURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%lu", (unsigned long)[[self class] version]]
                                                      isDirectory:YES];
    if (![_fileManager createDirectoryAtURL:versionURL withIntermediateDirectories:YES attributes:nil error:errorRef]) {
        return nil;
    }
    
    _fileURL = [[versionURL URLByAppendingPathComponent:[[self class] name]] copy];
    
    return _fileURL;
}

@end
