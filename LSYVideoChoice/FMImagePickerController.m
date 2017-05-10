//
//  FMImagePicker.m
//  FMRecordVideo
//
//  Created by qianjn on 2017/2/27.
//  Copyright © 2017年 SF. All rights reserved.
//

#import "FMImagePickerController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "AVFoundation/AVAssetExportSession.h"
#import <AVFoundation/AVFoundation.h>



@interface FMImagePickerController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

    
@end

@implementation FMImagePickerController
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (![self isVideoRecordingAvailable]) {
        return;
    }
    self.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.mediaTypes = @[(NSString *)kUTTypeMovie];
    self.delegate = self;
    
    //    //隐藏系统自带UI
    //    self.showsCameraControls = YES;
    //    //设置摄像头
    //    [self switchCameraIsFront:NO];
    //    //设置视频画质类别
    //    self.videoQuality = UIImagePickerControllerQualityTypeMedium;
    //    //设置散光灯类型
    //    self.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
    //    //设置录制的最大时长
    //    self.videoMaximumDuration = 20;
}

#pragma mark 自定义方法

- (void)startRecorder
{
    [self startVideoCapture];
}


- (void)stopRecoder
{
    [self stopVideoCapture];
}

#pragma mark - Private methods
- (BOOL)isVideoRecordingAvailable
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        if([availableMediaTypes containsObject:(NSString *)kUTTypeMovie]){
            return YES;
        }
    }
    return NO;
}

/*******************摄像头系切换*******************/

- (void)switchCameraIsFront:(BOOL)front
{
    if (front) {
        if([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]){
            [self setCameraDevice:UIImagePickerControllerCameraDeviceFront];
            
        }
    } else {
        if([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]){
            [self setCameraDevice:UIImagePickerControllerCameraDeviceRear];
            
        }
    }
}


//隐藏系统自带的UI，可以自定义UI
- (void)configureCustomUIOnImagePicker
{
    
    self.showsCameraControls = NO;
    
    UIView *cameraOverlay = [[UIView alloc] init];
    self.cameraOverlayView = cameraOverlay;
}

#pragma mark - UIImagePickerControllerDelegate methods

//- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
//{
//    //录制完的视频保存到相册
//    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//    NSURL *recordedVideoURL= [info objectForKey:UIImagePickerControllerMediaURL];
//    if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:recordedVideoURL]) {
//        [library writeVideoAtPathToSavedPhotosAlbum:recordedVideoURL
//                                    completionBlock:^(NSURL *assetURL, NSError *error){}
//         ];
//    }
//    
//    [picker dismissViewControllerAnimated:YES completion:nil];
//}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (CGFloat) getFileSize:(NSString *)path
{
    NSLog(@"%@",path);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    float filesize = -1.0;
    if ([fileManager fileExistsAtPath:path]) {
        NSDictionary *fileDic = [fileManager attributesOfItemAtPath:path error:nil];//获取文件的属性
        unsigned long long size = [[fileDic objectForKey:NSFileSize] longLongValue];
        filesize = 1.0*size/1024;
    }else{
        NSLog(@"找不到文件");
    }
    return filesize;
}//此方法可以获取文件的大小，返回的是单位是KB。
- (CGFloat) getVideoLength:(NSURL *)URL
{
    
    AVURLAsset *avUrl = [AVURLAsset assetWithURL:URL];
    CMTime time = [avUrl duration];
    int second = ceil(time.value/time.timescale);
    return second;
}//此方法可以获取视频文件的时长。

//完成视频录制，并压缩后显示大小、时长
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSURL *sourceURL = [info objectForKey:UIImagePickerControllerMediaURL];
    NSLog(@"%@",[NSString stringWithFormat:@"%f s", [self getVideoLength:sourceURL]]);
    NSLog(@"%@", [NSString stringWithFormat:@"%.2f kb", [self getFileSize:[sourceURL path]]]);
    NSURL *newVideoUrl ; //一般.mp4
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];//用时间给文件全名，以免重复，在测试的时候其实可以判断文件是否存在若存在，则删除，重新生成文件即可
//    [formater setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
//    newVideoUrl = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingFormat:@"/Documents/output-%@.mp4", [formater stringFromDate:[NSDate date]]]] ;//这个是保存在app自己的沙盒路径里，后面可以选择是否在上传后删除掉。我建议删除掉，免得占空间。
    newVideoUrl = [NSURL fileURLWithPath:[self getFilePathToSaveUnUpdatedImage]] ;
    [self convertVideoQuailtyWithInputURL:sourceURL outputURL:newVideoUrl completeHandler:nil];
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (NSString *)getFilePathToSaveUnUpdatedImage {
    NSString *filePath = [[self getImagesFilePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"Videos_%@.mp4", [NSString stringWithFormat:@"%.0f",[[NSDate new] timeIntervalSince1970] * 1000]]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
    return filePath;
}

- (NSString *)getImagesFilePath
{
    NSString *path = [NSString stringWithFormat:@"%@/Videos",NSTemporaryDirectory()];
    BOOL dictionary;
    if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&dictionary]) {
        //如果该目录不存在 则创建该目录
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}
- (void) convertVideoQuailtyWithInputURL:(NSURL*)inputURL
                               outputURL:(NSURL*)outputURL
                         completeHandler:(void (^)(AVAssetExportSession*))handler
{
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
    
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetMediumQuality];
    //  NSLog(resultPath);
    exportSession.outputURL = outputURL;
    exportSession.outputFileType = AVFileTypeMPEG4;
    exportSession.shouldOptimizeForNetworkUse= YES;
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void)
     {
         switch (exportSession.status) {
             case AVAssetExportSessionStatusCancelled:
                 NSLog(@"AVAssetExportSessionStatusCancelled");
                 break;
             case AVAssetExportSessionStatusUnknown:
                 NSLog(@"AVAssetExportSessionStatusUnknown");
                 break;
             case AVAssetExportSessionStatusWaiting:
                 NSLog(@"AVAssetExportSessionStatusWaiting");
                 break;
             case AVAssetExportSessionStatusExporting:
                 NSLog(@"AVAssetExportSessionStatusExporting");
                 break;
             case AVAssetExportSessionStatusCompleted:
             {
                 NSLog(@"AVAssetExportSessionStatusCompleted");
                 NSLog(@"%@",[NSString stringWithFormat:@"%f s", [self getVideoLength:outputURL]]);
                 NSLog(@"%@", [NSString stringWithFormat:@"%.2f kb", [self getFileSize:[outputURL path]]]);
                 
                 //UISaveVideoAtPathToSavedPhotosAlbum([outputURL path], self, nil, NULL);//这个是保存到手机相册
                 
//                 [self alertUploadVideo:outputURL];
                 dispatch_async(dispatch_get_main_queue(), ^{
                     self.finishVideoChoice([outputURL path]);
                 });
             }
                 break;
             case AVAssetExportSessionStatusFailed:
                 NSLog(@"AVAssetExportSessionStatusFailed");
                 break;
         }
         
     }];
    
}

@end
