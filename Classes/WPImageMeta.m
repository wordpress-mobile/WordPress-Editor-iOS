#import "WPImageMeta.h"

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
        [dict setObject:self.align forKey:@"alt"];
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
    self.align = [self stringForKey:@"align" inDictionary:dict];
    self.alt = [self stringForKey:@"alt" inDictionary:dict];
    self.attachmentId = [self stringForKey:@"attachment_id" inDictionary:dict];
    self.caption = [self stringForKey:@"caption" inDictionary:dict];
    self.captionClassName = [self stringForKey:@"captionClassName" inDictionary:dict];
    self.captionId = [self stringForKey:@"captionId" inDictionary:dict];
    self.classes = [self stringForKey:@"classes" inDictionary:dict];
    self.height = [self stringForKey:@"height" inDictionary:dict];
    self.link = [self boolForKey:@"link" inDictionary:dict];
    self.linkURL = [self stringForKey:@"linkUrl" inDictionary:dict];
    self.linkClassName = [self stringForKey:@"linkClassName" inDictionary:dict];
    self.linkTargetBlank = [self boolForKey:@"linkTargetBlank" inDictionary:dict];
    self.size = [self stringForKey:@"size" inDictionary:dict];
    self.src = [self stringForKey:@"src" inDictionary:dict];
    self.title = [self stringForKey:@"title" inDictionary:dict];
    self.width = [self stringForKey:@"width" inDictionary:dict];
}


#pragma mark - Safe Expectations

- (BOOL)boolForKey:(NSString *)key inDictionary:(NSDictionary *)dict
{
    if ([dict objectForKey:key]) {
        return [[dict objectForKey:key] boolValue];
    }
    return NO;
}

- (NSString *)stringForKey:(NSString *)key inDictionary:(NSDictionary *)dict
{
    id value = [dict objectForKey:key];
    if (value) {
        if ([value isKindOfClass:[NSString class]]) {
            return (NSString *)value;
        }
        if ([value respondsToSelector:@selector(stringValue)]) {
            return [value performSelector:@selector(stringValue)];
        }
    }
    return @"";
}

@end
