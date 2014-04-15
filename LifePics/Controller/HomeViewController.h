//
//  HomeViewController.h
//  LifePics
//
//  Created by Gabriel Moraes on 14/04/14.
//  Copyright (c) 2014 Gabriel Moraes. All rights reserved.
//

#import <UIKit/UIKit.h>

@import MobileCoreServices;

@interface HomeViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate,UIImagePickerControllerDelegate,
UINavigationControllerDelegate>

@property (strong, nonatomic) NSArray* arrMolduras;
@property (assign) BOOL newMedia;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end
