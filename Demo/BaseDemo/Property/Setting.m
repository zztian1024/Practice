//
//  Setting.m
//  Property
//
//  Created by Tian on 2020/10/30.
//

#import "Setting.h"

static NSString *_defaultAPIVersion;
static NSString *_defaultName = @"AppName";

#define SETTINGS_PLIST_CONFIGURATION_SETTING_IMPL(TYPE, PLIST_KEY, GETTER, SETTER, DEFAULT_VALUE, ENABLE_CACHE) \
static TYPE *g_ ## PLIST_KEY = nil; \
+ (TYPE *)GETTER \
{ \
if ((g_ ## PLIST_KEY == nil) && ENABLE_CACHE) { \
g_ ## PLIST_KEY = [[[NSUserDefaults standardUserDefaults] objectForKey:@#PLIST_KEY] copy]; \
} \
if (g_ ## PLIST_KEY == nil) { \
g_ ## PLIST_KEY = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@#PLIST_KEY] copy] ?: DEFAULT_VALUE; \
} \
return g_ ## PLIST_KEY; \
} \
+ (void)SETTER:(TYPE *)value { \
g_ ## PLIST_KEY = [value copy]; \
if (ENABLE_CACHE) { \
if (value != nil) { \
[[NSUserDefaults standardUserDefaults] setObject:value forKey:@#PLIST_KEY]; \
} else { \
[[NSUserDefaults standardUserDefaults] removeObjectForKey:@#PLIST_KEY]; \
} \
} \
}

@implementation Setting

+ (NSString *)name {
    return _defaultName;
}

+ (NSString *)APIVersion {
    return _defaultAPIVersion;
}

+ (void)setAPIVersion:(NSString *)APIVersion {
    if (![_defaultAPIVersion isEqualToString:APIVersion]) {
        _defaultAPIVersion = APIVersion;
    }
}
SETTINGS_PLIST_CONFIGURATION_SETTING_IMPL(NSNumber, JpegCompressionQuality, JPEGCompressionQuality, setJPEGCompressionQuality, @0.9, NO);
/**
 clang -rewrite-objc Setting.m
 上面的代码会被编译成为：
 
 static NSNumber *g_JpegCompressionQuality = __null;
 static NSNumber * _Nonnull _C_Setting_JPEGCompressionQuality(Class self, SEL _cmd) { if ((g_JpegCompressionQuality == __null) && ((bool)0)) { g_JpegCompressionQuality = ((id  _Nullable (*)(id, SEL))(void *)objc_msgSend)((id)((id  _Nullable (*)(id, SEL, NSString * _Nonnull))(void *)objc_msgSend)((id)((NSUserDefaults * _Nonnull (*)(id, SEL))(void *)objc_msgSend)((id)objc_getClass("NSUserDefaults"), sel_registerName("standardUserDefaults")), sel_registerName("objectForKey:"), (NSString *)&__NSConstantStringImpl__var_folders_ck_d98k_7vx0_b2z9zjxn5608980000gn_T_Setting_962172_mi_1), sel_registerName("copy")); } if (g_JpegCompressionQuality == __null) { g_JpegCompressionQuality = ((id  _Nullable (*)(id, SEL))(void *)objc_msgSend)((id)((id  _Nullable (*)(id, SEL, NSString * _Nonnull))(void *)objc_msgSend)((id)((NSBundle * _Nonnull (*)(id, SEL))(void *)objc_msgSend)((id)objc_getClass("NSBundle"), sel_registerName("mainBundle")), sel_registerName("objectForInfoDictionaryKey:"), (NSString *)&__NSConstantStringImpl__var_folders_ck_d98k_7vx0_b2z9zjxn5608980000gn_T_Setting_962172_mi_2), sel_registerName("copy")) ?: ((NSNumber *(*)(Class, SEL, double))(void *)objc_msgSend)(objc_getClass("NSNumber"), sel_registerName("numberWithDouble:"), 0.90000000000000002); } return g_JpegCompressionQuality; }
 static void _C_Setting_setJPEGCompressionQuality_(Class self, SEL _cmd, NSNumber * _Nonnull value) { g_JpegCompressionQuality = ((id (*)(id, SEL))(void *)objc_msgSend)((id)value, sel_registerName("copy")); if (((bool)0)) { if (value != __null) { ((void (*)(id, SEL, id _Nullable, NSString * _Nonnull))(void *)objc_msgSend)((id)((NSUserDefaults * _Nonnull (*)(id, SEL))(void *)objc_msgSend)((id)objc_getClass("NSUserDefaults"), sel_registerName("standardUserDefaults")), sel_registerName("setObject:forKey:"), (id _Nullable)value, (NSString *)&__NSConstantStringImpl__var_folders_ck_d98k_7vx0_b2z9zjxn5608980000gn_T_Setting_962172_mi_3); } else { ((void (*)(id, SEL, NSString * _Nonnull))(void *)objc_msgSend)((id)((NSUserDefaults * _Nonnull (*)(id, SEL))(void *)objc_msgSend)((id)objc_getClass("NSUserDefaults"), sel_registerName("standardUserDefaults")), sel_registerName("removeObjectForKey:"), (NSString *)&__NSConstantStringImpl__var_folders_ck_d98k_7vx0_b2z9zjxn5608980000gn_T_Setting_962172_mi_4); } } };
 */
@end
