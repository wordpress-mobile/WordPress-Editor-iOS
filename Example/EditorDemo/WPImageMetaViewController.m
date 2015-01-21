#import "WPImageMetaViewController.h"
#import <WordPress-iOS-Editor/WPImageMeta.h>

@interface WPImageMetaViewController ()

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIView *contentView;
@property (nonatomic, strong) IBOutlet UITextField *alignField;
@property (nonatomic, strong) IBOutlet UITextField *altField;
@property (nonatomic, strong) IBOutlet UITextField *attachmentIdField;
@property (nonatomic, strong) IBOutlet UITextField *captionField;
@property (nonatomic, strong) IBOutlet UITextField *captionClassNameField;
@property (nonatomic, strong) IBOutlet UITextField *classesField;
@property (nonatomic, strong) IBOutlet UITextField *heightField;
@property (nonatomic, strong) IBOutlet UITextField *linkClassNameField;
@property (nonatomic, strong) IBOutlet UITextField *linkField;
@property (nonatomic, strong) IBOutlet UITextField *linkTargetBlankField;
@property (nonatomic, strong) IBOutlet UITextField *linkURLField;
@property (nonatomic, strong) IBOutlet UITextField *sizeField;
@property (nonatomic, strong) IBOutlet UITextField *srcField;
@property (nonatomic, strong) IBOutlet UITextField *titleField;
@property (nonatomic, strong) IBOutlet UITextField *widthField;

@end

@implementation WPImageMetaViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.scrollView.contentSize = self.contentView.bounds.size;

    self.alignField.text = self.imageMeta.align;
    self.altField.text = self.imageMeta.alt;
    self.attachmentIdField.text = self.imageMeta.attachmentId;
    self.captionField.text = self.imageMeta.caption;
    self.captionClassNameField.text = self.imageMeta.captionClassName;
    self.classesField.text = self.imageMeta.classes;
    self.heightField.text = self.imageMeta.height;
    self.linkClassNameField.text = self.imageMeta.linkClassName;
    self.linkField.text = self.imageMeta.linkRel;
    self.linkTargetBlankField.text = [[NSNumber numberWithBool:self.imageMeta.linkTargetBlank] stringValue];
    self.linkURLField.text = self.imageMeta.linkURL;
    self.sizeField.text = self.imageMeta.size;
    self.srcField.text = self.imageMeta.src;
    self.titleField.text = self.imageMeta.title;
    self.widthField.text = self.imageMeta.width;

    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    tgr.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tgr];
}

- (void)updateImageMeta
{
    self.imageMeta.align = self.alignField.text;
    self.imageMeta.alt = self.altField.text;
    self.imageMeta.attachmentId = self.attachmentIdField.text;
    self.imageMeta.caption = self.captionField.text;
    self.imageMeta.captionClassName = self.captionClassNameField.text;
    self.imageMeta.classes = self.classesField.text;
    self.imageMeta.height = self.heightField.text;
    self.imageMeta.linkClassName = self.linkClassNameField.text;
    self.imageMeta.linkRel = self.linkField.text;
    self.imageMeta.linkTargetBlank = [self.linkTargetBlankField.text boolValue];
    self.imageMeta.linkURL = self.linkURLField.text;
    self.imageMeta.size = self.sizeField.text;
    self.imageMeta.src = self.srcField.text;
    self.imageMeta.title = self.titleField.text;
    self.imageMeta.width = self.widthField.text;
}

- (IBAction)handleCloseTapped:(id)sender
{
    [self updateImageMeta];
    [self.delegate imageMetaViewController:self didFinishEditingImageMeta:self.imageMeta];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dismissKeyboard
{
    [self.view endEditing:YES];
}

@end