#import "WPViewController.h"

@import Photos;
@import AVFoundation;
@import MobileCoreServices;
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

- (void)editorViewController:(WPEditorViewController *)editorViewController imagePasted:(UIImage *)image
{
    NSData *imageData = UIImageJPEGRepresentation(image, 0.9);
    
    [self addImageDataToContent:imageData];
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
    DDLogInfo(@"Media Removed: %@", mediaID);
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

- (void)addImageDataToContent:(NSData *)imageData
{
    NSString *imageID = [[NSUUID UUID] UUIDString];
    NSString *path = [NSString stringWithFormat:@"%@/%@.jpg", NSTemporaryDirectory(), imageID];
    [imageData writeToFile:path atomically:YES];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.editorView insertLocalImage:[[NSURL fileURLWithPath:path] absoluteString] uniqueId:imageID];
    });

    NSProgress *progress = [[NSProgress alloc] initWithParent:nil userInfo:@{ @"imageID": imageID, @"url": path }];
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

- (void)addImageAssetToContent:(PHAsset *)asset
{
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.synchronous = NO;
    options.networkAccessAllowed = YES;
    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    options.version = PHImageRequestOptionsVersionCurrent;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    
    [[PHImageManager defaultManager] requestImageDataForAsset:asset
                                                      options:options
                                                resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        [self addImageDataToContent:imageData];
    }];
}

- (void)addVideoAssetToContent:(PHAsset *)originalAsset
{
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.synchronous = NO;
    options.networkAccessAllowed = YES;
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    options.version = PHImageRequestOptionsVersionCurrent;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    NSString *videoID = [[NSUUID UUID] UUIDString];
    NSString *videoPath = [NSString stringWithFormat:@"%@%@.mov", NSTemporaryDirectory(), videoID];
    [[PHImageManager defaultManager] requestImageForAsset:originalAsset
                                               targetSize:[UIScreen mainScreen].bounds.size
                                              contentMode:PHImageContentModeAspectFit
                                                  options:options
                                            resultHandler:^(UIImage *image, NSDictionary * _Nullable info) {
        NSData *data = UIImageJPEGRepresentation(image, 0.7);
        NSString *posterImagePath = [NSString stringWithFormat:@"%@/%@.jpg", NSTemporaryDirectory(), [[NSUUID UUID] UUIDString]];
        [data writeToFile:posterImagePath atomically:YES];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.editorView insertInProgressVideoWithID:videoID
                                        usingPosterImage:[[NSURL fileURLWithPath:posterImagePath] absoluteString]];
        });
        PHVideoRequestOptions *videoOptions = [PHVideoRequestOptions new];
        videoOptions.networkAccessAllowed = YES;
        [[PHImageManager defaultManager] requestExportSessionForVideo:originalAsset
                                                              options:videoOptions
                                                         exportPreset:AVAssetExportPresetPassthrough
                                                        resultHandler:^(AVAssetExportSession * _Nullable exportSession, NSDictionary * _Nullable info) {
                                                            exportSession.outputFileType = (__bridge NSString*)kUTTypeQuickTimeMovie;
                                                            exportSession.shouldOptimizeForNetworkUse = YES;
                                                            exportSession.outputURL = [NSURL fileURLWithPath:videoPath];
                                                            [exportSession exportAsynchronouslyWithCompletionHandler:^{
                                                                if (exportSession.status != AVAssetExportSessionStatusCompleted) {
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
            
        }];
    }];
}

- (void)addAssetToContent:(NSURL *)assetURL
{
    PHFetchResult *assets = [PHAsset fetchAssetsWithALAssetURLs:@[assetURL] options:nil];
    if (assets.count < 1) {
        return;
    }
    PHAsset *asset = [assets firstObject];
        
    if (asset.mediaType == PHAssetMediaTypeVideo) {
        [self addVideoAssetToContent:asset];
    } if (asset.mediaType == PHAssetMediaTypeImage) {
        [self addImageAssetToContent:asset];
    }
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
            [self.editorView replaceLocalImageWithRemoteImage:[[NSURL fileURLWithPath:progress.userInfo[@"url"]] absoluteString] uniqueId:imageID mediaId:[@(arc4random()) stringValue]];
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
