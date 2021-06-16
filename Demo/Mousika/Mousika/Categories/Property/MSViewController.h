//
//  MSViewController.h
//  Mousika
//
//  Created by Tian on 2021/5/28.
//

#import <UIKit/UIKit.h>
@class MSViewController;
NS_ASSUME_NONNULL_BEGIN

@protocol MSViewControllerDelegate <NSObject>

@optional
- (void)viewControllerDidDoSomethingSuccess:(MSViewController *)vc;

@end

@interface MSViewController : UIViewController

// weak, for test
@property (nonatomic, weak) id<MSViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
