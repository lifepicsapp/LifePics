//
//  AlbumViewController.h
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
#import "Usuario.h"

@interface AlbumViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate,
    UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) NSCache* contextCache;
@property (strong, nonatomic) ACAccountStore* accountStore;
@property (strong, nonatomic) NSMutableArray* arrMolduras;
@property (strong, nonatomic) NSMutableArray* arrFotos;
@property (strong, nonatomic) UIRefreshControl* refreshTop;
@property (strong, nonatomic) UIRefreshControl* refreshBottom;
@property (strong, nonatomic) Foto *foto;
@property (strong, nonatomic) Usuario *usuario;
@property (assign) BOOL fotosGrandes;
@property (assign) BOOL recarrega;
@property (assign) BOOL seguindo;
@property (assign) int qtdAtual;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

- (void)carrega:(float)delay;

@end
