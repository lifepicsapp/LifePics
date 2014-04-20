//
//  SocialView.h
//  LifePics
//
//  Created by Gabriel Moraes on 19/04/14.
//  Copyright (c) 2014 Gabriel Moraes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Social.h"

@interface SocialView : UICollectionViewCell

@property (nonatomic, strong) Social* social;

@property (weak, nonatomic) IBOutlet UILabel *lblNome;
@property (weak, nonatomic) IBOutlet UIImageView *imgIcone;
@property (weak, nonatomic) IBOutlet UISwitch *swtAtivo;

@end
