//
//  NWAudioResourceLoader.h
//  Utility
//
//  Created by Tian on 2020/11/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NWAudioResourceLoader : NSObject

+ (instancetype)sharedLoader;

- (BOOL)loadSound:(NSError *__autoreleasing *)errorRef;
- (void)playSound;

@property (class, nullable, nonatomic, readonly, copy) NSString *name;
@property (class, nullable, nonatomic, readonly, copy) NSData *data;
@property (class, nonatomic, readonly, assign) NSUInteger version;

@end

NS_ASSUME_NONNULL_END
