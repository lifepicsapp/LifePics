//
//  HomeViewController.h
//  LifePics
//
//  Created by Gabriel Moraes on 14/04/14.
//  Copyright (c) 2014 Gabriel Moraes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+FotoBar.h"
#import "UIViewController+QuedaConexao.h"
#import <Accounts/Accounts.h>
#import "Moldura.h"
#import "Foto.h"

@interface HomeViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate,
    UICollectionViewDelegateFlowLayout, UIAlertViewDelegate>

@property (strong, nonatomic) ACAccountStore* accountStore;
@property (strong, nonatomic) NSArray* arrMolduras;
@property (strong, nonatomic) NSArray* arrFotos;
@property (strong, nonatomic) NSCache* cacheFotos;
@property (strong, nonatomic) Moldura *moldura;
@property (strong, nonatomic) Foto *foto;
@property (assign) BOOL fotosGrandes;
@property (assign) BOOL abriuLogado;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

- (void)carrega:(float)delay;

@end
