//
//  VideoItemCollectCell.h
//  Funny Clip
//
//  Created by nhannlt on 20/04/2015.
//  Copyright (c) Năm 2015 NhanNLT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoModel.h"
#import <UIImageView+AFNetworking.h>
#include "MarqueeLabel.h"
@interface VideoItemCollectCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *thumnailImg;

@property (weak, nonatomic) IBOutlet MarqueeLabel *titleLbl;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLb;
//- (void) initCellWithData: ();
+ (id) initViewOwner;
- (void) initDataWithVideoInfo: (VideoModel *) model;
@end
