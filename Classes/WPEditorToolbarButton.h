//
//  WPEditorToolbarButton.h
//  Pods
//
//  Created by Diego E. Rey Mendez on 8/22/14.
//
//

#import <UIKit/UIKit.h>

@interface WPEditorToolbarButton : UIButton

#pragma mark - Memory warnings support

/**
 *	@brief		Calling this method makes sure all memory that can be released will be released.
 */
- (void)didReceiveMemoryWarning;

@end
