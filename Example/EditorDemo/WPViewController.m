#import "WPViewController.h"

@import AssetsLibrary;
#import <CocoaLumberjack/DDLog.h>
#import "WPEditorField.h"
#import "WPEditorView.h"

typedef NS_ENUM(NSUInteger,  WPViewControllerActionSheet) {
    WPViewControllerActionSheetUploadStop = 200,
    WPViewControllerActionSheetUploadRetry = 201
};

@interface WPViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate>

@property(nonatomic, strong) NSMutableDictionary *imagesAdded;
@property(nonatomic, strong) NSString *selectedImageId;
@end

@implementation WPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.delegate = self;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit"
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:self
                                                                            action:@selector(editTouchedUpInside)];
    self.imagesAdded = [NSMutableDictionary dictionary];
}

#pragma mark - Navigation Bar

- (void)editTouchedUpInside
{
    if (self.isEditing) {
        [self stopEditing];
    } else {
        [self startEditing];
    }
}

#pragma mark - IBActions

- (IBAction)exit:(UIStoryboardSegue*)segue
{
}

#pragma mark - WPEditorViewControllerDelegate

- (void)editorDidBeginEditing:(WPEditorViewController *)editorController
{
    DDLogInfo(@"Editor did begin editing.");
}

- (void)editorDidEndEditing:(WPEditorViewController *)editorController
{
    DDLogInfo(@"Editor did end editing.");
}

- (void)editorDidFinishLoadingDOM:(WPEditorViewController *)editorController
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"content" ofType:@"html"];
    NSString *htmlParam = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [self setTitleText:@"I'm editing a post!"];
    [self setBodyText:htmlParam];
}

- (BOOL)editorShouldDisplaySourceView:(WPEditorViewController *)editorController
{
    return YES;
}

- (void)editorDidPressMedia:(WPEditorViewController *)editorController
{
    DDLogInfo(@"Pressed Media!");
    [self showPhotoPicker];
}

- (void)editorTitleDidChange:(WPEditorViewController *)editorController
{
    DDLogInfo(@"Editor title did change: %@", self.titleText);
}

- (void)editorTextDidChange:(WPEditorViewController *)editorController
{
    DDLogInfo(@"Editor body text changed: %@", self.bodyText);
}

- (void)editorViewController:(WPEditorViewController *)editorViewController fieldCreated:(WPEditorField*)field
{
    DDLogInfo(@"Editor field created: %@", field.nodeId);
}

- (void)editorViewController:(WPEditorViewController*)editorViewController
       imageTapped:(NSString *)imageId
               url:(NSURL *)url
{
    if (imageId.length == 0){
        return;
    }
    NSProgress * progress = self.imagesAdded[imageId];
    if (!progress.cancelled){
        UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Stop Upload" otherButtonTitles:nil];
        [actionSheet showInView:self.view];
        actionSheet.tag = WPViewControllerActionSheetUploadStop;
    } else {
        UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Remove Image" otherButtonTitles:@"Retry Upload", nil];
        [actionSheet showInView:self.view];
        actionSheet.tag = WPViewControllerActionSheetUploadRetry;
    }
    self.selectedImageId= imageId;
}

- (void)showPhotoPicker
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.navigationBar.translucent = NO;
    picker.modalPresentationStyle = UIModalPresentationCurrentContext;
    
    [self.navigationController presentViewController:picker animated:YES completion:nil];
}

- (void)addAssetToContent:(NSURL *)assetURL {
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    [assetsLibrary assetForURL:assetURL resultBlock:^(ALAsset *asset){
        UIImage * image = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
        NSData * data = UIImageJPEGRepresentation(image, 0.7);
        NSString * imageID = [[NSUUID UUID] UUIDString];
        NSString * path = [NSString stringWithFormat:@"%@/%@", NSTemporaryDirectory(), imageID];
        [data writeToFile:path atomically:YES];
        [self.editorView insertLocalImage:[[NSURL fileURLWithPath:path] absoluteString] uniqueId:imageID];
            
        NSProgress * progress = [[NSProgress alloc] initWithParent:nil userInfo:@{@"imageID":imageID, @"url":path}];
        progress.cancellable = YES;
        progress.totalUnitCount = 100;
        NSTimer * timer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                           target:self
                                                         selector:@selector(timerFireMethod:)
                                                         userInfo:progress
                                                          repeats:YES];
        self.imagesAdded[imageID] = progress;
    } failureBlock:^(NSError *error) {
        DDLogInfo(@"Failed to insert media: %@", [error localizedDescription]);
    }];
}

-(void)timerFireMethod:(NSTimer *)timer{
    NSProgress * progress = (NSProgress *)timer.userInfo;
    NSString * imageID = progress.userInfo[@"imageID"];
    progress.completedUnitCount++;
    [self.editorView setProgress:progress.fractionCompleted onImage:imageID];
//    if (progress.fractionCompleted >= 0.15){
//        [progress cancel];
//        [self.editorView markImage:imageID failedUploadWithMessage:@"Failed"];
//        [timer invalidate];
//    }
    if (progress.fractionCompleted >= 1){
        [self.editorView replaceLocalImageWithRemoteImage:[[NSURL fileURLWithPath:progress.userInfo[@"url"]] absoluteString] uniqueId:imageID];
        [self.imagesAdded removeObjectForKey:imageID];
        [timer invalidate];
    }
}

#pragma mark - UIImagePickerControllerDelegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        NSURL *assetURL = info[UIImagePickerControllerReferenceURL];
        [self addAssetToContent:assetURL];
    }];
    
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == WPViewControllerActionSheetUploadStop){
        if (buttonIndex == actionSheet.destructiveButtonIndex) {
            [self.editorView removeImage:self.selectedImageId];
        }
    } else if (actionSheet.tag == WPViewControllerActionSheetUploadRetry){
        if (buttonIndex == actionSheet.destructiveButtonIndex) {
            [self.editorView removeImage:self.selectedImageId];
        } else if (buttonIndex == actionSheet.firstOtherButtonIndex) {
            NSProgress * progress = [[NSProgress alloc] initWithParent:nil userInfo:@{@"imageID":self.selectedImageId}];
            progress.totalUnitCount = 100;
            NSTimer * timer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                               target:self
                                                             selector:@selector(timerFireMethod:)
                                                             userInfo:progress
                                                              repeats:YES];
            self.imagesAdded[self.selectedImageId] = progress;
            [self.editorView unmarkImageFailedUpload:self.selectedImageId];
        }

    }
    
    
}


@end
