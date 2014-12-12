#import <Foundation/Foundation.h>

@interface WPImageMeta : NSObject

@property (nonatomic, strong) NSString *align;
@property (nonatomic, strong) NSString *alt;
@property (nonatomic, strong) NSString *attachmentId;
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) NSString *captionClassName;
@property (nonatomic, strong) NSString *captionId;
@property (nonatomic, strong) NSString *classes;
@property (nonatomic, strong) NSString *height;
@property (nonatomic) BOOL link;
@property (nonatomic, strong) NSString *linkURL;
@property (nonatomic, strong) NSString *linkClassName;
@property (nonatomic) BOOL linkTargetBlank;
@property (nonatomic, strong) NSString *size;
@property (nonatomic, strong) NSString *src;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *width;

+ (instancetype)imageMetaFromJSONString:(NSString *)str;
- (NSString *)jsonStringRepresentation;

@end
