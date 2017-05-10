//
//  UIViewController+VideoChoice.h
//  nbOneMap
//
//  Created by shiyong_li on 17/4/18.
//  Copyright © 2017年 dist. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface UIViewController (VideoChoice)
- (void)addVideoWithfinishBlock:(void(^)(NSString *))finishBlock;
@end
