#import "WPEditorField.h"

#import "HRColorUtil.h"

static NSString* const kWPEditorFieldJavascriptFalse = @"false";
static NSString* const kWPEditorFieldJavascriptTrue = @"true";

@interface WPEditorField ()

/**
 *  @brief      A flag to indicate wether the DOM has been loaded or not.
 */
@property (nonatomic, assign, readwrite) BOOL domLoaded;

/**
 *  @brief      The web view to use for all javascript calls.
 */
@property (nonatomic, strong, readonly) WKWebView* webView;

#pragma mark - Properties: preloaded values

/**
 *  @brief      Serves as a temporary buffer to store any value set to the HTML of this field before
 *              the DOM is loaded.
 */
@property (nonatomic, copy, readwrite) NSString* preloadedHTML;

/**
 *  @brief      Serves as a temporary buffer to store any value set to the placeholderText of this
 *              field before the DOM is loaded.
 */
@property (nonatomic, copy, readwrite) UIColor* preloadedPlaceholderColor;

/**
 *  @brief      Serves as a temporary buffer to store any value set to the placeholderColor of this
 *              field before the DOM is loaded.
 */
@property (nonatomic, copy, readwrite) NSString* preloadedPlaceholderText;

@end

@implementation WPEditorField

#pragma mark - Initializers

/**
 *  @brief      We're disabling this initializer.  The correct one is initWithId:
 * 
 *  @returns    nil
 */
- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    self = nil;
    return self;
}

- (instancetype)initWithId:(NSString*)nodeId
                   webView:(WKWebView*)webView
{
    NSAssert([nodeId isKindOfClass:[NSString class]],
             @"We're expecting a non-nil NSString object here.");
    
    self = [super init];
    
    if (self) {
        _nodeId = nodeId;
        _webView = webView;
    }
    
    return self;
}

#pragma mark - DOM status

- (void)handleDOMLoaded
{
    NSAssert(!_domLoaded,
             @"This method should only be called once.");
    
    self.domLoaded = YES;
    
    [self setupInitialHTML];
    [self setupInitialPlaceholderText];
    [self setupInitialPlaceholderColor];
}

- (void)setupInitialHTML
{
    [self setHtml:self.preloadedHTML];
    self.preloadedHTML = nil;
}

- (void)setupInitialPlaceholderText
{
    [self setPlaceholderText:self.preloadedPlaceholderText];
    self.preloadedPlaceholderText = nil;
}

- (void)setupInitialPlaceholderColor
{
    [self setPlaceholderColor:self.preloadedPlaceholderColor];
    self.preloadedPlaceholderColor = nil;
}

#pragma mark - Node access

/**
 *  @brief      Returns the javascript string to obtain the wrapped node.
 */
- (NSString*)wrappedNodeJavascriptAccessor
{
    static NSString* const kWrappedNodeByIdFormat = @"ZSSEditor.getField(\"%@\")";
    
    NSString* wrappedNode = [NSString stringWithFormat:kWrappedNodeByIdFormat, self.nodeId];
    
    return wrappedNode;
}

#pragma mark - Editing lock

- (void)disableEditing
{
    NSString* javascript = [NSString stringWithFormat:@"%@.disableEditing();", [self wrappedNodeJavascriptAccessor]];
    [self.webView evaluateJavaScript:javascript completionHandler:^(id result, NSError *error) {
        if (error) {
            DDLogError(@"%@", [error localizedDescription]);
            return;
        }
    }];
}

- (void)enableEditing
{
    NSString* javascript = [NSString stringWithFormat:@"%@.enableEditing();", [self wrappedNodeJavascriptAccessor]];
    [self.webView evaluateJavaScript:javascript completionHandler:^(id result, NSError *error) {
        if (error) {
            DDLogError(@"%@", [error localizedDescription]);
            return;
        }
    }];
}

#pragma mark - HTML

- (void)html:(void (^)(NSString *result))completionHandler;
{
    NSString* html = nil;
    
    if (!self.domLoaded) {
        html = self.preloadedHTML;
        if (completionHandler) {
            completionHandler(html);
        }
    } else {
        NSString* javascript = [NSString stringWithFormat:@"%@.getHTML();", [self wrappedNodeJavascriptAccessor]];
        
        [self.webView evaluateJavaScript:javascript completionHandler:^(id result, NSError *error) {
            if (error) {
                DDLogError(@"%@", [error localizedDescription]);
                return;
            }
            NSString *textResult = (NSString *)result;
            if (completionHandler) {
                completionHandler(textResult);
            }
        }];

    }
}

- (void)strippedHtml:(void (^)(NSString *result))completionHandler;
{
    NSString* strippedHtml = nil;
    
    if (!self.domLoaded) {
        strippedHtml = self.preloadedHTML;
        if (completionHandler) {
            completionHandler(strippedHtml);
        }
    } else {
        NSString* javascript = [NSString stringWithFormat:@"%@.strippedHTML();", [self wrappedNodeJavascriptAccessor]];
        [self.webView evaluateJavaScript:javascript completionHandler:^(id result, NSError *error) {
            if (error) {
                DDLogError(@"%@", [error localizedDescription]);
                return;
            }
            NSString *textResult = (NSString *)result;
            if (completionHandler) {
                completionHandler(textResult);
            }
        }];

    }
}

- (void)setText:(NSString*)text
{
    if (!self.domLoaded) {
        self.preloadedHTML = text;
    } else {
        
        if (text) {
            text = [self addSlashes:text];
        } else {
            text = @"";
        }
        
        NSString* javascript = [NSString stringWithFormat:@"%@.setPlainText(\"%@\");", [self wrappedNodeJavascriptAccessor], text];
        
        [self.webView evaluateJavaScript:javascript completionHandler:^(id result, NSError *error) {
            if (error) {
                DDLogError(@"%@", [error localizedDescription]);
                return;
            }
        }];
    }
}

- (void)setHtml:(NSString*)html
{
    if (!self.domLoaded) {
        self.preloadedHTML = html;
    } else {
        
        if (html) {
            html = [self addSlashes:html];
        } else {
            html = @"";
        }
        
        NSString* javascript = [NSString stringWithFormat:@"%@.setHTML(\"%@\");", [self wrappedNodeJavascriptAccessor], html];

        [self.webView evaluateJavaScript:javascript completionHandler:^(id result, NSError *error) {
            if (error) {
                DDLogError(@"%@", [error localizedDescription]);
                return;
            }
        }];

    }
}

#pragma mark - Placeholder

- (void)setPlaceholderText:(NSString*)placeholderText
{
    if (!self.domLoaded) {
        self.preloadedPlaceholderText = placeholderText;
    } else {
        placeholderText = [self addSlashes:placeholderText];
        NSString* javascript = [NSString stringWithFormat:@"%@.setPlaceholderText(\"%@\");", [self wrappedNodeJavascriptAccessor], placeholderText];
        
        [self.webView evaluateJavaScript:javascript completionHandler:^(id result, NSError *error) {
            if (error) {
                DDLogError(@"%@", [error localizedDescription]);
                return;
            }
        }];

    }
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor
{
    if (!self.domLoaded) {
        self.preloadedPlaceholderColor = placeholderColor;
    } else {
        int hexColor = HexColorFromUIColor(placeholderColor);
        NSString* hexColorStr = [NSString stringWithFormat:@"#%06x", hexColor];
        
        NSString* javascript = [NSString stringWithFormat:@"%@.setPlaceholderColor(\"%@\");", [self wrappedNodeJavascriptAccessor], hexColorStr];
        
        [self.webView evaluateJavaScript:javascript completionHandler:^(id result, NSError *error) {
            if (error) {
                DDLogError(@"%@", [error localizedDescription]);
                return;
            }
        }];

    }
}

#pragma mark - URL & HTML utilities

/**
 *  @brief      Adds slashes to the specified HTML string, to prevent injections when calling JS
 *              code.
 *
 *  @param      html        The HTML string to add slashes to.  Cannot be nil.
 *
 *  @returns    The HTML string with the added slashes.
 */
- (NSString *)addSlashes:(NSString *)html
{
    html = [html stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    html = [html stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    html = [html stringByReplacingOccurrencesOfString:@"\r"  withString:@"\\r"];
    html = [html stringByReplacingOccurrencesOfString:@"\n"  withString:@"\\n"];
    
    return html;
}

#pragma mark - Focus

- (void)focus
{
    NSString* javascript = [NSString stringWithFormat:@"%@.focus();", [self wrappedNodeJavascriptAccessor]];
    [self.webView evaluateJavaScript:javascript completionHandler:^(id result, NSError *error) {
        if (error) {
            DDLogError(@"%@", [error localizedDescription]);
            return;
        }
    }];

}

- (void)blur
{
    NSString* javascript = [NSString stringWithFormat:@"%@.blur();", [self wrappedNodeJavascriptAccessor]];
    [self.webView evaluateJavaScript:javascript completionHandler:^(id result, NSError *error) {
        if (error) {
            DDLogError(@"%@", [error localizedDescription]);
            return;
        }
    }];

}

#pragma mark - i18n

- (void)isRightToLeftTextEnabled:(void (^)(BOOL result))completionHandler;
{
    NSString* javascript = [NSString stringWithFormat:@"%@.isRightToLeftTextEnabled();", [self wrappedNodeJavascriptAccessor]];
    [self.webView evaluateJavaScript:javascript completionHandler:^(id result, NSError *error) {
        if (error) {
            DDLogError(@"%@", [error localizedDescription]);
            return;
        }
        NSString *textResult = (NSString *)result;
        if (completionHandler) {
            completionHandler([textResult boolValue]);
        }
    }];
}

- (void)setRightToLeftTextEnabled:(BOOL)isRTL
{
    NSString* rtlString = nil;
    
    if (isRTL) {
        rtlString = kWPEditorFieldJavascriptTrue;
    } else {
        rtlString = kWPEditorFieldJavascriptFalse;
    }
    
    NSAssert([rtlString isKindOfClass:[NSString class]], @"Expected a non-nil NSString object here.");
    
    NSString* javascript = [NSString stringWithFormat:@"%@.enableRightToLeftText(%@);", [self wrappedNodeJavascriptAccessor], rtlString];
    [self.webView evaluateJavaScript:javascript completionHandler:^(id result, NSError *error) {
        if (error) {
            DDLogError(@"%@", [error localizedDescription]);
            return;
        }
    }];

}

#pragma mark - Settings

- (void)isMultiline:(void (^)(BOOL result))completionHandler;
{
    NSString* javascript = [NSString stringWithFormat:@"%@.isMultiline();", [self wrappedNodeJavascriptAccessor]];
    [self.webView evaluateJavaScript:javascript completionHandler:^(id result, NSError *error) {
        if (error) {
            DDLogError(@"%@", [error localizedDescription]);
            return;
        }
        NSString *textResult = (NSString *)result;
        if (completionHandler) {
            completionHandler([textResult boolValue]);
        }
    }];
}

- (void)setMultiline:(BOOL)multiline
{
    NSString* multilineString = nil;
    
    if (multiline) {
        multilineString = kWPEditorFieldJavascriptTrue;
    } else {
        multilineString = kWPEditorFieldJavascriptFalse;
    }
    
    NSAssert([multilineString isKindOfClass:[NSString class]],
             @"Expected a non-nil NSString object here.");
    
    NSString* javascript = [NSString stringWithFormat:@"%@.setMultiline(%@);", [self wrappedNodeJavascriptAccessor], multilineString];
    [self.webView evaluateJavaScript:javascript completionHandler:^(id result, NSError *error) {
        if (error) {
            DDLogError(@"%@", [error localizedDescription]);
            return;
        }
    }];

}

@end
