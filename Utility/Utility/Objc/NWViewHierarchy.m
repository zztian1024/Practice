//
//  NWViewHierarchy.m
//  Utility
//
//  Created by Tian on 2020/10/30.
//

#import "NWViewHierarchy.h"
#import "NSMutableArray+Safe.h"
#import "NSMutableDictionary+Safe.h"

#define MAX_VIEW_HIERARCHY_LEVEL 35

void nw_dispatch_on_main_thread(dispatch_block_t block) {
    if (block != nil) {
        if ([NSThread isMainThread]) {
            block();
        } else {
            dispatch_async(dispatch_get_main_queue(), block);
        }
    }
}

void nw_dispatch_on_default_thread(dispatch_block_t block) {
    if (block != nil) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
    }
}

@implementation NWViewHierarchy

+ (nullable NSArray *)getChildren:(NSObject *)obj {
    if ([obj isKindOfClass:[UIControl class]]) {
        return nil;
    }
    
    NSMutableArray *children = [NSMutableArray array];
    
    // children of window should be viewcontroller
    if ([obj isKindOfClass:[UIWindow class]]) {
        UIViewController *rootVC = ((UIWindow *)obj).rootViewController;
        NSArray<UIView *> *subviews = ((UIWindow *)obj).subviews;
        for (UIView *child in subviews) {
            if (child != rootVC.view) {
                UIViewController *vc = [NWViewHierarchy getParentViewController:child];
                if (vc != nil && vc.view == child) {
                    [children safe_addObject:vc];
                } else {
                    [children safe_addObject:child];
                }
            } else {
                if (rootVC) {
                    [children safe_addObject:rootVC];
                }
            }
        }
    } else if ([obj isKindOfClass:[UIView class]]) {
        NSArray<UIView *> *subviews = [((UIView *)obj).subviews copy];
        for (UIView *child in subviews) {
            UIViewController *vc = [NWViewHierarchy getParentViewController:child];
            if (vc && vc.view == child) {
                [children safe_addObject:vc];
            } else {
                [children safe_addObject:child];
            }
        }
    } else if ([obj isKindOfClass:[UINavigationController class]]) {
        UIViewController *vc = ((UINavigationController *)obj).visibleViewController;
        UIViewController *tc = ((UINavigationController *)obj).topViewController;
        NSArray *nextChildren = [NWViewHierarchy getChildren:((UIViewController *)obj).view];
        for (NSObject *child in nextChildren) {
            if (tc && [self isView:child superViewOfView:tc.view]) {
                [children safe_addObject:tc];
            } else if (vc && [self isView:child superViewOfView:vc.view]) {
                [children safe_addObject:vc];
            } else {
                if (child != vc.view && child != tc.view) {
                    [children safe_addObject:child];
                } else {
                    if (vc && child == vc.view) {
                        [children safe_addObject:vc];
                    } else if (tc && child == tc.view) {
                        [children safe_addObject:tc];
                    }
                }
            }
        }
        
        if (vc && ![children containsObject:vc]) {
            [children addObject:vc];
        }
    } else if ([obj isKindOfClass:[UITabBarController class]]) {
        UIViewController *vc = ((UITabBarController *)obj).selectedViewController;
        NSArray *nextChildren = [NWViewHierarchy getChildren:((UIViewController *)obj).view];
        for (NSObject *child in nextChildren) {
            if (vc && [self isView:child superViewOfView:vc.view]) {
                [children safe_addObject:vc];
            } else {
                if (vc && child == vc.view) {
                    [children safe_addObject:vc];
                } else {
                    [children safe_addObject:child];
                }
            }
        }
        
        if (vc && ![children containsObject:vc]) {
            [children safe_addObject:vc];
        }
    } else if ([obj isKindOfClass:[UIViewController class]]) {
        UIViewController *vc = (UIViewController *)obj;
        if (vc.isViewLoaded) {
            NSArray *nextChildren = [NWViewHierarchy getChildren:vc.view];
            if (nextChildren.count > 0) {
                [children addObjectsFromArray:nextChildren];
            }
        }
        for (NSObject *child in vc.childViewControllers) {
            [children safe_addObject:child];
        }
        UIViewController *presentedVC = vc.presentedViewController;
        if (presentedVC) {
            [children safe_addObject:presentedVC];
        }
    }
    return children;
}

+ (nullable NSObject *)getParent:(nullable NSObject *)obj {
    if ([obj isKindOfClass:[UIView class]]) {
        UIView *superview = ((UIView *)obj).superview;
        UIViewController *superviewViewController = [NWViewHierarchy getParentViewController:superview];
        if (superviewViewController && superviewViewController.view == superview) {
            return superviewViewController;
        }
        if (superview && superview != obj) {
            return superview;
        }
    } else if ([obj isKindOfClass:[UIViewController class]]) {
        UIViewController *vc = (UIViewController *)obj;
        UIViewController *parentVC = vc.parentViewController;
        UIViewController *presentingVC = vc.presentingViewController;
        UINavigationController *nav = vc.navigationController;
        UITabBarController *tab = vc.tabBarController;
        
        if (nav) {
            return nav;
        }
        
        if (tab) {
            return tab;
        }
        
        if (parentVC) {
            return parentVC;
        }
        
        if (presentingVC && presentingVC.presentedViewController == vc) {
            return presentingVC;
        }
        
        // Return parent of view of UIViewController
        NSObject *viewParent = [NWViewHierarchy getParent:vc.view];
        if (viewParent) {
            return viewParent;
        }
    }
    return nil;
}

+ (nullable NSArray *)getPath:(NSObject *)obj {
    return [NWViewHierarchy getPath:obj limit:MAX_VIEW_HIERARCHY_LEVEL];
}

+ (nullable NSArray *)getPath:(NSObject *)obj limit:(int)limit {
    if (!obj || limit <= 0) {
        return nil;
    }
    
    NSMutableArray *path;
    
    NSObject *parent = [NWViewHierarchy getParent:obj];
    if (parent) {
        NSArray *parentPath = [NWViewHierarchy getPath:parent limit:limit - 1];
        path = [NSMutableArray arrayWithArray:parentPath];
    } else {
        path = [NSMutableArray array];
    }
    
    //    NSDictionary *componentInfo = [NWViewHierarchy getAttributesOf:obj parent:parent];
    //
    //    FBSDKCodelessPathComponent *pathComponent = [[FBSDKCodelessPathComponent alloc]
    //                                                 initWithJSON:componentInfo];
    //    [path addObject:pathComponent];
    
    return [NSArray arrayWithArray:path];
}

+ (nullable UIViewController *)getParentViewController:(UIView *)view {
    UIResponder *parentResponder = view;
    
    while (parentResponder) {
        parentResponder = parentResponder.nextResponder;
        if ([parentResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)parentResponder;
        }
    }
    
    return nil;
}

+ (BOOL)isView:(NSObject *)obj1 superViewOfView:(UIView *)obj2 {
    if (![obj1 isKindOfClass:[UIView class]]
        || ![obj2 isKindOfClass:[UIView class]]) {
        return NO;
    }
    UIView *view1 = (UIView *)obj1;
    UIView *view2 = (UIView *)obj2;
    UIView *superview = view2;
    while (superview) {
        superview = superview.superview;
        if (superview == view1) {
            return YES;
        }
    }
    
    return NO;
}
@end
