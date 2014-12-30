#import <UIKit/UIKit.h>

@class WPImageMeta;
@class WPImageMetaViewController;

@protocol WPImageMetaViewControllerDelegate <NSObject>

- (void)imageMetaViewController:(WPImageMetaViewController *)controller didFinishEditingImageMeta:(WPImageMeta *)imageMeta;

@end

/**
 A view controller that presents a simple form for editing `WPImageMeta` properties.
 No consideration is given how a change in on property might affect related propreties
 and only serves to illustrate how changes to WPImageMeta are reflected in the
 HTML source.
 */
@interface WPImageMetaViewController : UIViewController

@property (nonatomic, weak) id<WPImageMetaViewControllerDelegate>delegate;
@property (nonatomic, strong) WPImageMeta *imageMeta;

@end
