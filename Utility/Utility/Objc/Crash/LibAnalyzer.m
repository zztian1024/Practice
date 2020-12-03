//
//  LibAnalyzer.m
//  Utility
//
//  Created by Tian on 2020/10/28.
//

#import "LibAnalyzer.h"
#import "NSMutableArray+Safe.h"
#import "NSMutableDictionary+Safe.h"

#import <objc/runtime.h>

@implementation LibAnalyzer

static NSMutableDictionary<NSString *, NSString *> *_methodMapping;

+ (void)initialize
{
  _methodMapping = [NSMutableDictionary dictionary];
}

+ (NSDictionary<NSString *, NSString *> *)getMethodsTable:(NSArray<NSString *> *)prefixes
                                               frameworks:(NSArray<NSString *> *)frameworks
{
  NSArray<NSString *> *allClasses = [self getClassNames:prefixes frameworks:frameworks];
  for (NSString *className in allClasses) {
    Class class = NSClassFromString(className);
    if (class) {
      [self addClass:class isClassMethod:NO];
      [self addClass:object_getClass(class) isClassMethod:YES];
    }
  }
  @synchronized(_methodMapping) {
    return [_methodMapping copy];
  }
}

#pragma mark - private methods

+ (NSArray<NSString *> *)getClassNames:(NSArray<NSString *> *)prefixes
                            frameworks:(NSArray<NSString *> *)frameworks
{
  NSMutableArray<NSString *> *classNames = [NSMutableArray new];
  // from main bundle
  [classNames addObjectsFromArray:[self getClassesFrom:[[NSBundle mainBundle] executablePath]
                                              prefixes:prefixes]];
  // from dynamic libraries
  if (frameworks.count > 0) {
    unsigned int count = 0;
    const char **images = objc_copyImageNames(&count);
    for (int i = 0; i < count; i++) {
      NSString *image = [NSString stringWithUTF8String:images[i]];
      for (NSString *framework in frameworks) {
        if ([image containsString:framework]) {
          [classNames addObjectsFromArray:[self getClassesFrom:image
                                                      prefixes:nil]];
        }
      }
    }
    free(images);
  }

  return [classNames copy];
}

+ (NSArray<NSString *> *)getClassesFrom:(NSString *)image
                               prefixes:(NSArray<NSString *> *)prefixes
{
  NSMutableArray<NSString *> *classNames = [NSMutableArray array];
  unsigned int count = 0;
  const char **classes = objc_copyClassNamesForImage([image UTF8String], &count);
  for (unsigned int i = 0; i < count; i++) {
    NSString *className = [NSString stringWithUTF8String:classes[i]];
    if (prefixes.count > 0) {
      for (NSString *prefix in prefixes) {
        if ([className hasPrefix:prefix]) {
          [classNames safe_addObject:className];
          break;
        }
      }
    } else {
      [classNames safe_addObject:className];
    }
  }
  free(classes);
  return [classNames copy];
}

+ (void)addClass:(Class)class
   isClassMethod:(BOOL)isClassMethod
{
  unsigned int methodsCount = 0;
  Method *methods = class_copyMethodList(class, &methodsCount);

  NSString *methodType = isClassMethod ? @"+" : @"-";

  for (unsigned int i = 0; i < methodsCount; i++) {
    Method method = methods[i];

    if (method) {
      SEL selector = method_getName(method);

      IMP methodImplementation = class_getMethodImplementation(class, selector);
      NSString *methodAddress = [NSString stringWithFormat:@"0x%010lx", (unsigned long)methodImplementation];
      NSString *methodName = [NSString stringWithFormat:@"%@[%@ %@]",
                              methodType,
                              NSStringFromClass(class),
                              NSStringFromSelector(selector)];

      if (methodAddress && methodName) {
        @synchronized(_methodMapping) {
          [_methodMapping safe_setObject:methodName forKey:methodAddress];
        }
      }
    }
  }
  free(methods);
}

+ (NSArray<NSString *> *)symbolicateCallstack:(NSArray<NSString *> *)callstack
                                methodMapping:(NSDictionary<NSString *, id> *)methodMapping
{
  if (!callstack || !methodMapping) {
    return nil;
  }
  NSArray<NSString *> *sortedAllAddress = [methodMapping.allKeys sortedArrayUsingComparator:^NSComparisonResult (id _Nonnull obj1, id _Nonnull obj2) {
    return [obj1 compare:obj2];
  }];

  BOOL containsFBSDKFunction = NO;
  NSInteger nonSDKMethodCount = 0;
  NSMutableArray<NSString *> *symbolicatedCallstack = [NSMutableArray array];

  for (NSUInteger i = 0; i < callstack.count; i++) {
    NSString *rawAddress = [self getAddress:[callstack safe_objectAtIndex:i]];
    NSString *addressString = [NSString stringWithFormat:@"0x%@", [rawAddress substringWithRange:NSMakeRange(rawAddress.length - 10, 10)]];
    NSString *methodAddress = [self searchMethod:addressString sortedAllAddress:sortedAllAddress];

    if (methodAddress) {
      containsFBSDKFunction = YES;
      nonSDKMethodCount == 0 ?: [symbolicatedCallstack safe_addObject:[NSString stringWithFormat:@"(%ld DEV METHODS)", (long)nonSDKMethodCount]];
      nonSDKMethodCount = 0;
      NSString *methodName = [methodMapping objectForKey:methodAddress];

      // filter out cxx_destruct
      if ([methodName containsString:@".cxx_destruct"]) {
        return nil;
      }
      [symbolicatedCallstack safe_addObject:[NSString stringWithFormat:@"%@%@", methodName, [self getOffset:addressString secondString:methodAddress]]];
    } else {
      nonSDKMethodCount++;
    }
  }
  nonSDKMethodCount == 0 ?: [symbolicatedCallstack safe_addObject:[NSString stringWithFormat:@"(%ld DEV METHODS)", (long)nonSDKMethodCount]];

  return containsFBSDKFunction ? symbolicatedCallstack : nil;
}

+ (NSString *)getAddress:(NSString *)callstackEntry
{
  NSArray<NSString *> *components = [callstackEntry componentsSeparatedByString:@" "];
  for (NSString *component in components) {
    if ([component containsString:@"0x"]) {
      return component;
    }
  }
  return nil;
}

+ (NSString *)getOffset:(NSString *)firstString
           secondString:(NSString *)secondString
{
  if (!firstString || !secondString) {
    return nil;
  }
  unsigned long long first = 0, second = 0;
  NSScanner *scanner = [NSScanner scannerWithString:firstString];
  [scanner scanHexLongLong:&first];

  scanner = [NSScanner scannerWithString:secondString];
  [scanner scanHexLongLong:&second];

  unsigned long long difference = first - second;
  return [NSString stringWithFormat:@"+%llu", difference];
}

+ (NSString *)searchMethod:(NSString *)address
          sortedAllAddress:(NSArray<NSString *> *)sortedAllAddress
{
  if (0 == sortedAllAddress.count) {
    return nil;
  }
  NSString *lowestAddress = [sortedAllAddress safe_objectAtIndex:0];
  NSString *highestAddress = [sortedAllAddress safe_objectAtIndex:sortedAllAddress.count - 1];

  if ([address compare:lowestAddress] == NSOrderedAscending || [address compare:highestAddress] == NSOrderedDescending) {
    return nil;
  }

  if ([address compare:lowestAddress] == NSOrderedSame) {
    return lowestAddress;
  }

  if ([address compare:highestAddress] == NSOrderedSame) {
    return highestAddress;
  }

  NSUInteger index = [sortedAllAddress indexOfObject:address
                                       inSortedRange:NSMakeRange(0, sortedAllAddress.count - 1)
                                             options:NSBinarySearchingInsertionIndex
                                     usingComparator:^NSComparisonResult (id _Nonnull obj1, id _Nonnull obj2) {
                                       return [obj1 compare:obj2];
                                     }];
  return [sortedAllAddress safe_objectAtIndex:index - 1];
}

@end
