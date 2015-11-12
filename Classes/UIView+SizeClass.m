#import "UIView+SizeClass.h"

@implementation UIView (SizeClass)

- (BOOL)isViewHorizontallyCompact
{
    // iOS <= 8:
    // We'll just consider 'Compact' all of non iPad Devices
    if ([self respondsToSelector:@selector(traitCollection)] == false) {
        return ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) == false;
    }
    
    return self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact;
}

@end
