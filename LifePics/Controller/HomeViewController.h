//
//  HomeViewController.h
//  LifePics
//
//  Created by Gabriel Moraes on 14/04/14.
//  Copyright (c) 2014 Gabriel Moraes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Moldura.h"
#import "Foto.h"

@interface HomeViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate,
    UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) NSArray* arrMolduras;
@property (strong, nonatomic) NSArray* arrFotos;
@property (strong, nonatomic) NSCache* cacheFotos;
@property (strong, nonatomic) Moldura *moldura;
@property (strong, nonatomic) Foto *foto;
@property (assign) BOOL fotosGrandes;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

- (void)carrega;

@end
