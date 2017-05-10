//
//  UIViewController+VideoChoice.m
//  nbOneMap
//
//  Created by shiyong_li on 17/4/18.
//  Copyright © 2017年 dist. All rights reserved.
//

#import "UIViewController+VideoChoice.h"
#import "FMImagePickerController.h"

@implementation UIViewController (VideoChoice)
- (void)addVideoWithfinishBlock:(void (^)(NSString *))finishBlock
{
    FMImagePickerController *imagePickerController = [[FMImagePickerController alloc]init];
    [imagePickerController setFinishVideoChoice:^(NSString *path) {
        finishBlock(path);
    }];
    [self presentViewController:imagePickerController animated:YES completion:nil];
}
@end
