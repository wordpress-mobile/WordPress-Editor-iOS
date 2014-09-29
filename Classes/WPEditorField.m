//
//  WPEditorField.m
//  Pods
//
//  Created by Diego E. Rey Mendez on 9/26/14.
//
//

#import "WPEditorField.h"

@interface WPEditorField ()
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
{
    NSAssert([nodeId isKindOfClass:[NSString class]],
             @"We're expecting a non-nil NSString object here.");
    
    self = [super init];
    
    if (self) {
        _nodeId = nodeId;
    }
    
    return self;
}

@end
