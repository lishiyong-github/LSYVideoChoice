//
//  FMImagePicker.h
//  FMRecordVideo
//
//  Created by qianjn on 2017/2/27.
//  Copyright © 2017年 SF. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface FMImagePickerController : UIImagePickerController
@property (nonatomic,copy) void (^finishVideoChoice)(NSString *path);
@end
