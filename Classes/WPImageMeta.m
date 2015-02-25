#import "WPImageMeta.h"
#import "NSObject+SafeExpectations.h"

static NSString *const MetaKeyAlign             = @"align";
static NSString *const MetaKeyAlt               = @"alt";
static NSString *const MetaKeyAttachmentId      = @"attachment_id";
static NSString *const MetaKeyCaption           = @"caption";
static NSString *const MetaKeyCaptionClassName  = @"captionClassName";
static NSString *const MetaKeyCaptionId         = @"captionId";
static NSString *const MetaKeyClasses           = @"classes";
static NSString *const MetaKeyHeight            = @"height";
static NSString *const MetaKeyLinkClassName     = @"linkClassName";
static NSString *const MetaKeyLinkTargetBlank   = @"linkTargetBlank";
static NSString *const MetaKeyLinkRel           = @"linkRel";
static NSString *const MetaKeyLinkUrl           = @"linkUrl";
static NSString *const MetaKeySize              = @"size";
static NSString *const MetaKeySrc               = @"src";
static NSString *const MetaKeyTitle             = @"title";
static NSString *const MetaKeyWidth             = @"width";
static NSString *const MetaKeyNaturalWidth      = @"naturalWidth";
static NSString *const MetaKeyNaturalHeight     = @"naturalHeight";

@interface WPImageMeta()
@property (nonatomic, readwrite) NSString *captionId;
@end

@implementation WPImageMeta

+ (instancetype)imageMetaFromJSONString:(NSString *)str
{
    NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    if (error) {
        NSLog(@"Error parsing JSON string: %@", error);
    }

    WPImageMeta *meta = [[WPImageMeta alloc] init];
    [meta parseDictionary:dict];
    return meta;
}

- (NSString *)jsonStringRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (self.align) {
        [dict setObject:self.align forKey:MetaKeyAlign];
    }
    if (self.alt) {
        [dict setObject:self.alt forKey:MetaKeyAlt];
    }
    if (self.attachmentId) {
        [dict setObject:self.attachmentId forKey:MetaKeyAttachmentId];
    }
    if (self.caption) {
        [dict setObject:self.caption forKey:MetaKeyCaption];
    }
    if (self.captionClassName) {
        [dict setObject:self.captionClassName forKey:MetaKeyCaptionClassName];
    }
    if (self.captionId) {
        [dict setObject:self.captionId forKey:MetaKeyCaptionId];
    }
    if (self.classes) {
        [dict setObject:self.classes forKey:MetaKeyClasses];
    }
    if (self.height) {
        [dict setObject:self.height forKey:MetaKeyHeight];
    }
    if (self.linkClassName) {
        [dict setObject:self.linkClassName forKey:MetaKeyLinkClassName];
    }

    [dict setObject:@(self.linkTargetBlank) forKey:MetaKeyLinkTargetBlank];

    if (self.linkRel) {
        [dict setObject:self.linkRel forKey:MetaKeyLinkRel];
    }
    if (self.linkURL) {
        [dict setObject:self.linkURL forKey:MetaKeyLinkUrl];
    }
    if (self.size) {
        [dict setObject:self.size forKey:MetaKeySize];
    }
    if (self.src) {
        [dict setObject:self.src forKey:MetaKeySrc];
    }
    if (self.title) {
        [dict setObject:self.title forKey:MetaKeyTitle];
    }
    if (self.width) {
        [dict setObject:self.width forKey:MetaKeyWidth];
    }
    if (self.naturalWidth) {
        [dict setObject:self.naturalWidth forKey:MetaKeyNaturalWidth];
    }
    if (self.naturalHeight) {
        [dict setObject:self.naturalHeight forKey:MetaKeyNaturalHeight];
    }

    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    NSString *str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return str;
}

/**
 Parses the passed dictionary and updates instance property values with
 the values of the dictionary. 
 Properties that not included in the dictionary are set to an empty string.

 @param dict A dictionary with keys matching any of the "MetaKey" consts.
 */
- (void)parseDictionary:(NSDictionary *)dict
{
    // Set captionId first in case its not defined in the passed dictionary, but
    // attachmentId is.
    self.captionId = [dict stringForKey:MetaKeyCaptionId];

    self.align = [dict stringForKey:MetaKeyAlign];
    self.alt = [dict stringForKey:MetaKeyAlt];
    self.attachmentId = [dict stringForKey:MetaKeyAttachmentId];
    self.caption = [dict stringForKey:MetaKeyCaption];
    self.captionClassName = [dict stringForKey:MetaKeyCaptionClassName];
    self.classes = [dict stringForKey:MetaKeyClasses];
    self.height = [dict stringForKey:MetaKeyHeight];
    self.linkClassName = [dict stringForKey:MetaKeyLinkClassName];
    self.linkRel = [dict stringForKey:MetaKeyLinkRel];
    self.linkTargetBlank = [[dict numberForKey:MetaKeyLinkTargetBlank] boolValue];
    self.linkURL = [dict stringForKey:MetaKeyLinkUrl];
    self.size = [dict stringForKey:MetaKeySize];
    self.src = [dict stringForKey:MetaKeySrc];
    self.title = [dict stringForKey:MetaKeyTitle];
    self.width = [dict stringForKey:MetaKeyWidth];
    self.naturalWidth = [dict stringForKey:MetaKeyNaturalWidth];
    self.naturalHeight = [dict stringForKey:MetaKeyNaturalHeight];
}

/**
 Acceptable values are numeric strings.
 */
- (void)setAttachmentId:(NSString *)attachmentId
{
    _attachmentId = [self numericOrEmptyString:attachmentId];
    self.captionId = _attachmentId;
}

/**
 The value of `captionId` is derivative of the value of `attachmentId`. Setting the
 `attachmentId` also updates the value of `captionId`.
 Caption id enforces a string format of "attachment_" followed by a numeric value.
 The passed string value is sanitized and reformatted accordingly.
 */
- (void)setCaptionId:(NSString *)captionId
{
    NSString *str = [self numericOrEmptyString:captionId];
    if ([str length]) {
        str = [NSString stringWithFormat:@"attachment_%@", str];
    }
    _captionId = str;
}

/**
 Returns the first integer value from the passed string, or an empty string if no
 integer value was found. 
 
 @param str The string to parse.
 @return A numeric string or an empty string.
 */
- (NSString *)numericOrEmptyString:(NSString *)str
{
    NSString *tmpStr = @"";
    if ([str length]) {
        NSInteger intval = [str integerValue];
        if (intval > 0) {
            tmpStr = [NSString stringWithFormat:@"%ld", (long)intval];
        }
    }
    return tmpStr;
}

@end
