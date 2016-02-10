#import "WKWebView+GUIFixes.h"
#import <objc/runtime.h>

@implementation WKWebView (GUIFixes)

static const char* const kCustomInputAccessoryView = "kCustomInputAccessoryView";
static const char* const fixedClassName = "WKWebBrowserViewMinusAccessoryView";
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

	UIView* parentWebView = self.superview;
	
	while (parentWebView && ![parentWebView isKindOfClass:[WKWebView class]])
	{
		parentWebView = parentWebView.superview;
	}
	
	view = [(WKWebView*)parentWebView customInputAccessoryView];
	
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
		
		[self fixAssistNodeMethodForClass:newClass];
		
        fixClass = newClass;
    }
}

- (void)fixAssistNodeMethodForClass:(Class)class
{
	__weak typeof(self) weakSelf = self;
	
	SEL sel = sel_getUid("_startAssistingNode:userIsInteracting:blurPreviousNode:userObject:");
	Method method = class_getInstanceMethod(class, sel);
	IMP originalImp = method_getImplementation(method);
	IMP imp = imp_implementationWithBlock(^void(id me, void* arg0, BOOL arg1, BOOL arg2, id arg3) {
		
		if (!weakSelf.isLoading) {
			((void (*)(id, SEL, void*, BOOL, BOOL, id))originalImp)(me, sel, arg0, TRUE, arg2, arg3);
		} else {
			((void (*)(id, SEL, void*, BOOL, BOOL, id))originalImp)(me, sel, arg0, arg1, arg2, arg3);
		}
	});
	method_setImplementation(method, imp);
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
    } else {
        Class normalClass = objc_getClass("WKContent");
        object_setClass(browserView, normalClass);
    }
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
