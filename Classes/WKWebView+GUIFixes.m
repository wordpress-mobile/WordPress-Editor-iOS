#import "WKWebView+GUIFixes.h"
#import <objc/runtime.h>

@implementation WKWebView (GUIFixes)

static const char* const kCustomInputAccessoryView = "kCustomInputAccessoryView";
static const char* const fixedClassName = "UIWebBrowserViewMinusAccessoryView";
static Class fixClass = Nil;

- (UIView *)browserView
{
    UIScrollView *scrollView = self.scrollView;
    
    UIView *browserView = nil;
    for (UIView *subview in scrollView.subviews) {
        if ([NSStringFromClass([subview class]) hasPrefix:@"WKContent"]) {
            browserView = subview;
            break;
        }
    }
	
    return browserView;
}

- (id)methodReturningCustomInputAccessoryView
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
	UIView* view = [self performSelector:@selector(originalInputAccessoryView) withObject:nil];
#pragma clang diagnostic pop
	
	if (view) {
		
		UIView* parentWebView = self.superview;
		
		while (parentWebView && ![parentWebView isKindOfClass:[WKWebView class]])
		{
			parentWebView = parentWebView.superview;
		}
		
		view = [(WKWebView*)parentWebView customInputAccessoryView];
	}
	
	return view;
}

- (void)ensureFixedSubclassExistsOfBrowserViewClass:(Class)browserViewClass
{
    if (!fixClass) {
        Class newClass = objc_allocateClassPair(browserViewClass, fixedClassName, 0);
		IMP oldImp = class_getMethodImplementation(browserViewClass, @selector(inputAccessoryView));
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
		class_addMethod(newClass, @selector(originalInputAccessoryView), oldImp, "@@:");
#pragma clang diagnostic pop
		
        IMP newImp = [self methodForSelector:@selector(methodReturningCustomInputAccessoryView)];
        class_addMethod(newClass, @selector(inputAccessoryView), newImp, "@@:");
        objc_registerClassPair(newClass);
        
        fixClass = newClass;
    }
}

- (BOOL)usesGUIFixes
{
    UIView *browserView = [self browserView];
    return [browserView class] == fixClass;
}

- (void)setUsesGUIFixes:(BOOL)value
{
    UIView *browserView = [self browserView];
    if (browserView == nil) {
        return;
    }
   
	[self ensureFixedSubclassExistsOfBrowserViewClass:[browserView class]];

    if (value) {
        object_setClass(browserView, fixClass);
    }
    else {
        Class normalClass = objc_getClass("WKContent");
        object_setClass(browserView, normalClass);
    }
	
    [browserView reloadInputViews];
}

- (UIView*)customInputAccessoryView
{
	return objc_getAssociatedObject(self, kCustomInputAccessoryView);
}

- (void)setCustomInputAccessoryView:(UIView*)view
{
	objc_setAssociatedObject(self,
							 kCustomInputAccessoryView,
							 view,
							 OBJC_ASSOCIATION_RETAIN);
}

@end
