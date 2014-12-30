#import "WPImageMeta.h"
#import "NSObject+SafeExpectations.h"

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
        [dict setObject:self.align forKey:@"align"];
    }
    if (self.alt) {
        [dict setObject:self.alt forKey:@"alt"];
    }
    if (self.attachmentId) {
        [dict setObject:self.attachmentId forKey:@"attachment_id"];
    }
    if (self.caption) {
        [dict setObject:self.caption forKey:@"caption"];
    }
    if (self.captionId) {
        [dict setObject:self.captionId forKey:@"captionId"];
    }
    if (self.classes) {
        [dict setObject:self.classes forKey:@"classes"];
    }
    if (self.height) {
        [dict setObject:self.height forKey:@"height"];
    }

    [dict setObject:@(self.link) forKey:@"link"];

    if (self.linkURL) {
        [dict setObject:self.linkURL forKey:@"linkUrl"];
    }
    if (self.linkClassName) {
        [dict setObject:self.linkClassName forKey:@"linkClassName"];
    }

    [dict setObject:@(self.linkTargetBlank) forKey:@"linkTargetBlank"];

    if (self.size) {
        [dict setObject:self.size forKey:@"size"];
    }
    if (self.src) {
        [dict setObject:self.src forKey:@"src"];
    }
    if (self.title) {
        [dict setObject:self.title forKey:@"title"];
    }
    if (self.width) {
        [dict setObject:self.width forKey:@"width"];
    }

    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    NSString *str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return str;
}

- (void)parseDictionary:(NSDictionary *)dict
{
    self.align = [dict stringForKey:@"align"];
    self.alt = [dict stringForKey:@"alt"];
    self.attachmentId = [dict stringForKey:@"attachment_id"];
    self.caption = [dict stringForKey:@"caption"];
    self.captionClassName = [dict stringForKey:@"captionClassName"];
    self.captionId = [dict stringForKey:@"captionId"];
    self.classes = [dict stringForKey:@"classes"];
    self.height = [dict stringForKey:@"height"];
    self.link = [[dict numberForKey:@"link"] boolValue];
    self.linkURL = [dict stringForKey:@"linkUrl"];
    self.linkClassName = [dict stringForKey:@"linkClassName"];
    self.linkTargetBlank = [[dict numberForKey:@"linkTargetBlank"] boolValue];
    self.size = [dict stringForKey:@"size"];
    self.src = [dict stringForKey:@"src"];
    self.title = [dict stringForKey:@"title"];
    self.width = [dict stringForKey:@"width"];
}

@end
