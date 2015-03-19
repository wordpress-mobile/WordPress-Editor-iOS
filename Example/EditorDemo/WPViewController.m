#import "WPViewController.h"

@import AssetsLibrary;
@import AVFoundation;
#import <CocoaLumberjack/DDLog.h>
#import "WPEditorField.h"
#import "WPEditorView.h"
#import "WPImageMetaViewController.h"

typedef NS_ENUM(NSUInteger,  WPViewControllerActionSheet) {
    WPViewControllerActionSheetUploadStop = 200,
    WPViewControllerActionSheetUploadRetry = 201
};

@interface WPViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, WPImageMetaViewControllerDelegate>
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [self.editorView saveSelection];
    [super prepareForSegue:segue sender:sender];
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
                   imageMeta:(WPImageMeta *)imageMeta
{

    if (imageId.length == 0) {
        [self showImageDetailsForImageMeta:imageMeta];
    } else {
        [self showPromptForImageWithID:imageId];
    }
}

- (void)editorViewController:(WPEditorViewController *)editorViewController imageReplaced:(NSString *)imageId
{
    [self.imagesAdded removeObjectForKey:imageId];
}

- (void)showImageDetailsForImageMeta:(WPImageMeta *)imageMeta
{
    WPImageMetaViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"WPImageMetaViewController"];
    controller.imageMeta = imageMeta;
    controller.delegate = self;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    [self.navigationController presentViewController:navController animated:YES completion:nil];
}

- (void)showPromptForImageWithID:(NSString *)imageId
{
    if (imageId.length == 0){
        return;
    }
    NSProgress *progress = self.imagesAdded[imageId];
    if (!progress.cancelled){
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Stop Upload" otherButtonTitles:nil];
        [actionSheet showInView:self.view];
        actionSheet.tag = WPViewControllerActionSheetUploadStop;
    } else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Remove Image" otherButtonTitles:@"Retry Upload", nil];
        [actionSheet showInView:self.view];
        actionSheet.tag = WPViewControllerActionSheetUploadRetry;
    }
    self.selectedImageId = imageId;
}

- (void)showPhotoPicker
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.navigationBar.translucent = NO;
    picker.modalPresentationStyle = UIModalPresentationCurrentContext;
    picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:picker.sourceType];
    [self.navigationController presentViewController:picker animated:YES completion:nil];
}

- (void)addImageAssetToContent:(ALAsset *)asset
{
    UIImage *image = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
    NSData *data = UIImageJPEGRepresentation(image, 0.7);
    NSString *imageID = [[NSUUID UUID] UUIDString];
    NSString *path = [NSString stringWithFormat:@"%@/%@.jpg", NSTemporaryDirectory(), imageID];
    [data writeToFile:path atomically:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.editorView insertLocalImage:[[NSURL fileURLWithPath:path] absoluteString] uniqueId:imageID];
    });

    NSProgress *progress = [[NSProgress alloc] initWithParent:nil userInfo:@{ @"imageID": imageID,
                                                                              @"url": path }];
    progress.cancellable = YES;
    progress.totalUnitCount = 100;
    [NSTimer scheduledTimerWithTimeInterval:0.1
                                     target:self
                                   selector:@selector(timerFireMethod:)
                                   userInfo:progress
                                    repeats:YES];
    self.imagesAdded[imageID] = progress;
}

- (void)addVideoAssetToContent:(ALAsset *)originalAsset
{
    UIImage *image = [UIImage imageWithCGImage:[originalAsset thumbnail]];
    NSData *data = UIImageJPEGRepresentation(image, 0.7);
    NSString *posterImagePath = [NSString stringWithFormat:@"%@/%@.jpg", NSTemporaryDirectory(), [[NSUUID UUID] UUIDString]];
    [data writeToFile:posterImagePath atomically:YES];

    ALAssetRepresentation *representation = originalAsset.defaultRepresentation;
    AVAsset *asset = [AVURLAsset URLAssetWithURL:representation.url options:nil];
    NSString *videoID = [[NSUUID UUID] UUIDString];
    NSString *videoPath = [NSString stringWithFormat:@"%@%@.mov", NSTemporaryDirectory(), videoID];
    NSString *presetName = AVAssetExportPresetPassthrough;
    AVAssetExportSession *session = [AVAssetExportSession exportSessionWithAsset:asset presetName:presetName];
    session.outputFileType = representation.UTI;
    session.shouldOptimizeForNetworkUse = YES;
    session.outputURL = [NSURL fileURLWithPath:videoPath];
    [session exportAsynchronouslyWithCompletionHandler:^{
        if (session.status != AVAssetExportSessionStatusCompleted) {
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.editorView insertVideo:[[NSURL fileURLWithPath:videoPath] absoluteString]
                             posterImage:[[NSURL fileURLWithPath:posterImagePath] absoluteString]
                                     alt:@"Video"];
        });
    }];
}

- (void)addAssetToContent:(NSURL *)assetURL
{
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    [assetsLibrary assetForURL:assetURL resultBlock:^(ALAsset *asset) {
        
        if ([asset valueForProperty:ALAssetPropertyType] == ALAssetTypeVideo) {
            [self addVideoAssetToContent:asset];
        } if ([asset valueForProperty:ALAssetPropertyType] == ALAssetTypePhoto) {
            [self addImageAssetToContent:asset];
        }
    } failureBlock:^(NSError *error) {
        DDLogInfo(@"Failed to insert media: %@", [error localizedDescription]);
    }];
}

-(void)timerFireMethod:(NSTimer *)timer{
    NSProgress * progress = (NSProgress *)timer.userInfo;
    NSString * imageID = progress.userInfo[@"imageID"];
    progress.completedUnitCount++;
    [self.editorView setProgress:progress.fractionCompleted onImage:imageID];

// Uncomment this code if you need to test a failed image upload
//    if (progress.fractionCompleted >= 0.15){
//        [progress cancel];
//        [self.editorView markImage:imageID failedUploadWithMessage:@"Failed"];
//        [timer invalidate];
//    }
    
    if (progress.fractionCompleted >= 1){
        [self.editorView replaceLocalImageWithRemoteImage:[[NSURL fileURLWithPath:progress.userInfo[@"url"]] absoluteString] uniqueId:imageID];
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
            [NSTimer scheduledTimerWithTimeInterval:0.1
                                             target:self
                                           selector:@selector(timerFireMethod:)
                                           userInfo:progress
                                            repeats:YES];
            self.imagesAdded[self.selectedImageId] = progress;
            [self.editorView unmarkImageFailedUpload:self.selectedImageId];
        }

    }
    
    
}

#pragma mark - WPImageMetaViewControllerDelegate

- (void)imageMetaViewController:(WPImageMetaViewController *)controller didFinishEditingImageMeta:(WPImageMeta *)imageMeta
{
    [self.editorView updateCurrentImageMeta:imageMeta];
}

@end
