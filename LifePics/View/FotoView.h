//
//  FotoView.h
//  LifePics
//
//  Created by Gabriel Moraes on 22/04/14.
//  Copyright (c) 2014 Gabriel Moraes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FotoView : UIView

@property (nonatomic, strong) IBOutlet UILabel* lblStatus;
@property (nonatomic, strong) IBOutlet UIImageView* imgFoto;
@property (nonatomic, strong) IBOutlet UIImageView* imgOK;
@property (nonatomic, strong) IBOutlet UIProgressView
* pvUpload;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView* aiCarregando;

typedef enum
{
    FotoBarOptionUpload,
    FotoBarOptionFacebook,
    FotoBarOptionTwitter,
    FotoBarOptionInstagram
} FotoBarOptions;

@end
