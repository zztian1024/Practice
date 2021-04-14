//
//  NWDeviceInfo.m
//  Utility
//
//  Created by Tian on 2020/11/1.
//

#import "NWDeviceInfo.h"

#import <sys/sysctl.h>
#import <sys/utsname.h>

#if !TARGET_OS_TV
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#endif

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// Apple reports storage in binary gigabytes (1024^3) in their About menus, etc.
static const u_int FB_GIGABYTE = 1024 * 1024 * 1024; // bytes

@implementation NWDeviceInfo
{
    NSString *_timeZoneAbbrev;
    unsigned long long _remainingDiskSpaceGB;
    NSString *_timeZoneName;
    
    // Persistent data, but we maintain it to make rebuilding the device info as fast as possible.
    NSString *_bundleIdentifier;
    NSString *_longVersion;
    NSString *_shortVersion;
    NSString *_sysVersion;
    NSString *_machine;
    NSString *_language;
    unsigned long long _totalDiskSpaceGB;
    unsigned long long _coreCount;
    CGFloat _width;
    CGFloat _height;
    CGFloat _density;
    
}

#pragma mark - Internal Methods

+ (void)initialize {
    if (self == [NWDeviceInfo class]) {
        [[self sharedDeviceInfo] _collectPersistentData];
    }
}

+ (instancetype)sharedDeviceInfo {
    static NWDeviceInfo *_sharedDeviceInfo = nil;
    if (_sharedDeviceInfo == nil) {
        _sharedDeviceInfo = [[NWDeviceInfo alloc] init];
    }
    return _sharedDeviceInfo;
}

// This data need only be collected once.
- (void)_collectPersistentData {
    // Bundle stuff
    NSBundle *mainBundle = [NSBundle mainBundle];
    _bundleIdentifier = mainBundle.bundleIdentifier;
    _longVersion = [mainBundle objectForInfoDictionaryKey:@"CFBundleVersion"];
    _shortVersion = [mainBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    // Locale stuff
    _language = [NSLocale currentLocale].localeIdentifier;
    
    // Device stuff
    UIDevice *device = [UIDevice currentDevice];
    _sysVersion = device.systemVersion;
    
    UIScreen *sc = [UIScreen mainScreen];
    CGRect sr = sc.bounds;
    _width = sr.size.width;
    _height = sr.size.height;
    _density = sc.scale;
    
    struct utsname systemInfo;
    uname(&systemInfo);
    _machine = @(systemInfo.machine);
    
    // Disk space stuff
    float totalDiskSpace = [NWDeviceInfo getTotalDiskSpace].floatValue;
    _totalDiskSpaceGB = (unsigned long long)round(totalDiskSpace / FB_GIGABYTE);
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
+ (NSString *)getCarrier {
#if TARGET_OS_TV || TARGET_IPHONE_SIMULATOR
    return @"NoCarrier";
#else
    // Dynamically load class for this so calling app doesn't need to link framework in.
    CTTelephonyNetworkInfo *networkInfo = [[nwsdkdfl_CTTelephonyNetworkInfoClass() alloc] init];
    CTCarrier *carrier = networkInfo.subscriberCellularProvider;
    return carrier.carrierName ?: @"NoCarrier";
#endif
}

#pragma clang diagnostic pop

+ (NSNumber *)getRemainingDiskSpace {
    NSDictionary *attrs = [[[NSFileManager alloc] init] attributesOfFileSystemForPath:NSHomeDirectory()
                                                                                error:nil];
    return attrs[NSFileSystemFreeSize];
}

+ (NSNumber *)getTotalDiskSpace {
    NSDictionary *attrs = [[[NSFileManager alloc] init] attributesOfFileSystemForPath:NSHomeDirectory()
                                                                                error:nil];
    return attrs[NSFileSystemSize];
}
@end
