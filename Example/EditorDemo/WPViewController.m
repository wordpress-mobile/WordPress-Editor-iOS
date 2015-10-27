#import "WPViewController.h"

@import AssetsLibrary;
@import AVFoundation;
#import <CocoaLumberjack/CocoaLumberjack.h>
#import "WPEditorField.h"
#import "WPEditorView.h"
#import "WPImageMetaViewController.h"

@interface WPViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, WPImageMetaViewControllerDelegate>
@property(nonatomic, strong) NSMutableDictionary *mediaAdded;
@property(nonatomic, strong) NSString *selectedMediaID;
@property(nonatomic, strong) NSCache *videoPressCache;

@end

@implementation WPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.delegate = self;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(editTouchedUpInside)];
    self.mediaAdded = [NSMutableDictionary dictionary];
    self.videoPressCache = [[NSCache alloc] init];
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
    [self.editorView pauseAllVideos];
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

- (void)editorViewController:(WPEditorViewController*)editorViewController
                 videoTapped:(NSString *)videoId
                         url:(NSURL *)url
{
    [self showPromptForVideoWithID:videoId];
}

- (void)editorViewController:(WPEditorViewController *)editorViewController imageReplaced:(NSString *)imageId
{
    [self.mediaAdded removeObjectForKey:imageId];
}

- (void)editorViewController:(WPEditorViewController *)editorViewController videoReplaced:(NSString *)videoId
{
    [self.mediaAdded removeObjectForKey:videoId];
}

- (void)editorViewController:(WPEditorViewController *)editorViewController videoPressInfoRequest:(NSString *)videoID
{
    NSDictionary * videoPressInfo = [self.videoPressCache objectForKey:videoID];
    NSString * videoURL = videoPressInfo[@"source"];
    NSString * posterURL = videoPressInfo[@"poster"];
    if (videoURL) {
        [self.editorView setVideoPress:videoID source:videoURL poster:posterURL];
    }
}

- (void)editorViewController:(WPEditorViewController *)editorViewController mediaRemoved:(NSString *)mediaID
{
    NSProgress * progress = self.mediaAdded[mediaID];
    [progress cancel];
}

- (void)editorFormatBarStatusChanged:(WPEditorViewController *)editorController
                             enabled:(BOOL)isEnabled
{
    DDLogInfo(@"Editor format bar status is now %@.", (isEnabled ? @"enabled" : @"disabled"));
}

#pragma mark - Media actions

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
    
    __weak __typeof(self)weakSelf = self;
    UITraitCollection *traits = self.navigationController.traitCollection;
    NSProgress *progress = self.mediaAdded[imageId];
    UIAlertController *alertController;
    if (traits.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        alertController = [UIAlertController alertControllerWithTitle:nil
                                                              message:nil
                                                       preferredStyle:UIAlertControllerStyleAlert];
    } else {
        alertController = [UIAlertController alertControllerWithTitle:nil
                                                              message:nil
                                                       preferredStyle:UIAlertControllerStyleActionSheet];
    }
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *action){}];
    [alertController addAction:cancelAction];
    
    if (!progress.cancelled){
        UIAlertAction *stopAction = [UIAlertAction actionWithTitle:@"Stop Upload"
                                                             style:UIAlertActionStyleDestructive
                                                           handler:^(UIAlertAction *action){
                                                               [weakSelf.editorView removeImage:weakSelf.selectedMediaID];
                                                           }];
        [alertController addAction:stopAction];
    } else {
        UIAlertAction *removeAction = [UIAlertAction actionWithTitle:@"Remove Image"
                                                               style:UIAlertActionStyleDestructive
                                                             handler:^(UIAlertAction *action){
                                                                 [weakSelf.editorView removeImage:weakSelf.selectedMediaID];
                                                             }];
        
        UIAlertAction *retryAction = [UIAlertAction actionWithTitle:@"Retry Upload"
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction *action){
                                                                NSProgress * progress = [[NSProgress alloc] initWithParent:nil userInfo:@{@"imageID":self.selectedMediaID}];
                                                                progress.totalUnitCount = 100;
                                                                [NSTimer scheduledTimerWithTimeInterval:0.1
                                                                                                 target:self
                                                                                               selector:@selector(timerFireMethod:)
                                                                                               userInfo:progress
                                                                                                repeats:YES];
                                                                weakSelf.mediaAdded[weakSelf.selectedMediaID] = progress;
                                                                [weakSelf.editorView unmarkImageFailedUpload:weakSelf.selectedMediaID];
                                                            }];
        [alertController addAction:removeAction];
        [alertController addAction:retryAction];
    }
    
    self.selectedMediaID = imageId;
    [self.navigationController presentViewController:alertController animated:YES completion:nil];
}

- (void)showPromptForVideoWithID:(NSString *)videoId
{
    if (videoId.length == 0){
        return;
    }
    __weak __typeof(self)weakSelf = self;
    UITraitCollection *traits = self.navigationController.traitCollection;
    NSProgress *progress = self.mediaAdded[videoId];
    UIAlertController *alertController;
    if (traits.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        alertController = [UIAlertController alertControllerWithTitle:nil
                                                              message:nil
                                                       preferredStyle:UIAlertControllerStyleAlert];
    } else {
        alertController = [UIAlertController alertControllerWithTitle:nil
                                                              message:nil
                                                       preferredStyle:UIAlertControllerStyleActionSheet];
    }
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *action){}];
    [alertController addAction:cancelAction];
    
    if (!progress.cancelled){
        UIAlertAction *stopAction = [UIAlertAction actionWithTitle:@"Stop Upload"
                                                             style:UIAlertActionStyleDestructive
                                                           handler:^(UIAlertAction *action){
                                                               [weakSelf.editorView removeVideo:weakSelf.selectedMediaID];
                                                           }];
        [alertController addAction:stopAction];
    } else {
        UIAlertAction *removeAction = [UIAlertAction actionWithTitle:@"Remove Video"
                                                               style:UIAlertActionStyleDestructive
                                                             handler:^(UIAlertAction *action){
                                                                 [weakSelf.editorView removeVideo:weakSelf.selectedMediaID];
                                                             }];
        
        UIAlertAction *retryAction = [UIAlertAction actionWithTitle:@"Retry Upload"
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction *action){
                                                                NSProgress * progress = [[NSProgress alloc] initWithParent:nil userInfo:@{@"videoID":weakSelf.selectedMediaID}];
                                                                progress.totalUnitCount = 100;
                                                                [NSTimer scheduledTimerWithTimeInterval:0.1
                                                                                                 target:self
                                                                                               selector:@selector(timerFireMethod:)
                                                                                               userInfo:progress
                                                                                                repeats:YES];
                                                                weakSelf.mediaAdded[self.selectedMediaID] = progress;
                                                                [weakSelf.editorView unmarkVideoFailedUpload:weakSelf.selectedMediaID];
                                                            }];
        [alertController addAction:removeAction];
        [alertController addAction:retryAction];
    }
    self.selectedMediaID = videoId;
    [self.navigationController presentViewController:alertController animated:YES completion:nil];
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
    NSTimer * timer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                     target:self
                                   selector:@selector(timerFireMethod:)
                                   userInfo:progress
                                    repeats:YES];
    [progress setCancellationHandler:^{
        [timer invalidate];
    }];
    self.mediaAdded[imageID] = progress;
}

- (void)addVideoAssetToContent:(ALAsset *)originalAsset
{
    UIImage *image = [UIImage imageWithCGImage:originalAsset.defaultRepresentation.fullScreenImage];
    NSData *data = UIImageJPEGRepresentation(image, 0.7);
    NSString *posterImagePath = [NSString stringWithFormat:@"%@/%@.jpg", NSTemporaryDirectory(), [[NSUUID UUID] UUIDString]];
    [data writeToFile:posterImagePath atomically:YES];
    NSString *videoID = [[NSUUID UUID] UUIDString];
    [self.editorView insertInProgressVideoWithID:videoID
                                usingPosterImage:[[NSURL fileURLWithPath:posterImagePath] absoluteString]];
    ALAssetRepresentation *representation = originalAsset.defaultRepresentation;
    AVAsset *asset = [AVURLAsset URLAssetWithURL:representation.url options:nil];
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
            NSProgress *progress = [[NSProgress alloc] initWithParent:nil
                                                             userInfo:@{@"videoID": videoID, @"url": videoPath, @"poster": posterImagePath }];
            progress.cancellable = YES;
            progress.totalUnitCount = 100;
            [NSTimer scheduledTimerWithTimeInterval:0.1
                                             target:self
                                           selector:@selector(timerFireMethod:)
                                           userInfo:progress
                                            repeats:YES];
            self.mediaAdded[videoID] = progress;
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

- (void)timerFireMethod:(NSTimer *)timer
{
    NSProgress *progress = (NSProgress *)timer.userInfo;
    progress.completedUnitCount++;
    NSString *imageID = progress.userInfo[@"imageID"];
    if (imageID) {
        [self.editorView setProgress:progress.fractionCompleted onImage:imageID];
        // Uncomment this code if you need to test a failed image upload
        //    if (progress.fractionCompleted >= 0.15){
        //        [progress cancel];
        //        [self.editorView markImage:imageID failedUploadWithMessage:@"Failed"];
        //        [timer invalidate];
        //    }
        if (progress.fractionCompleted >= 1) {
            [self.editorView replaceLocalImageWithRemoteImage:[[NSURL fileURLWithPath:progress.userInfo[@"url"]] absoluteString] uniqueId:imageID];
            [timer invalidate];
        }
        return;
    }

    NSString *videoID = progress.userInfo[@"videoID"];
    if (videoID) {
        [self.editorView setProgress:progress.fractionCompleted onVideo:videoID];
        // Uncomment this code if you need to test a failed video upload
//        if (progress.fractionCompleted >= 0.15) {
//            [progress cancel];
//            [self.editorView markVideo:videoID failedUploadWithMessage:@"Failed"];
//            [timer invalidate];
//        }
        if (progress.fractionCompleted >= 1) {
            NSString * videoURL = [[NSURL fileURLWithPath:progress.userInfo[@"url"]] absoluteString];
            NSString * posterURL = [[NSURL fileURLWithPath:progress.userInfo[@"poster"]] absoluteString];
            [self.editorView replaceLocalVideoWithID:videoID
                                      forRemoteVideo:videoURL
                                        remotePoster:posterURL
                                          videoPress:videoID];
            [self.videoPressCache setObject:@ {@"source":videoURL, @"poster":posterURL} forKey:videoID];
            [timer invalidate];
        }
        return;
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

#pragma mark - WPImageMetaViewControllerDelegate

- (void)imageMetaViewController:(WPImageMetaViewController *)controller didFinishEditingImageMeta:(WPImageMeta *)imageMeta
{
    [self.editorView updateCurrentImageMeta:imageMeta];
}

@end
