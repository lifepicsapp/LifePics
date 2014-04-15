//
//  HomeViewController.h
//  LifePics
//
//  Created by Gabriel Moraes on 14/04/14.
//  Copyright (c) 2014 Gabriel Moraes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "Moldura.h"

@import MobileCoreServices;

@interface HomeViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, MBProgressHUDDelegate>

@property (strong, nonatomic) NSArray* arrMolduras;
@property (strong, nonatomic) NSArray* arrFotos;
@property (assign) BOOL newMedia;
@property (strong, nonatomic) MBProgressHUD *HUD;
@property (strong, nonatomic) Moldura *moldura;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end
