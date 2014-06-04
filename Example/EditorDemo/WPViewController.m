#import "WPViewController.h"

@interface WPViewController ()

@end

@implementation WPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - WPEditorViewControllerDelegate

- (void)editorDidPressSettings:(WPEditorViewController *)editorController
{
    NSLog(@"Pressed Settings!");
}

- (void)editorDidPressMedia:(WPEditorViewController *)editorController
{
    NSLog(@"Pressed Media!");
}

- (void)editorDidPressPreview:(WPEditorViewController *)editorController
{
    NSLog(@"Pressed Preview!");
}

@end
