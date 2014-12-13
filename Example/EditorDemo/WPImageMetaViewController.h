#import <UIKit/UIKit.h>

@class WPImageMeta;
@class WPImageMetaViewController;

@protocol WPImageMetaViewControllerDelegate <NSObject>

- (void)imageMetaViewController:(WPImageMetaViewController *)controller didFinishEditingImageMeta:(WPImageMeta *)imageMeta;

@end

@interface WPImageMetaViewController : UIViewController

@property (nonatomic, weak) id<WPImageMetaViewControllerDelegate>delegate;
@property (nonatomic, strong) WPImageMeta *imageMeta;

@end
