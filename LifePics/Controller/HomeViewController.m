//
//  HomeViewController.m
//  LifePics
//
//  Created by Gabriel Moraes on 14/04/14.
//  Copyright (c) 2014 Gabriel Moraes. All rights reserved.
//

#import "HomeViewController.h"
#import <Parse/Parse.h>
#import "MolduraView.h"
#import "PerfilView.h"
#import "FotoViewController.h"
#import <CCBottomRefreshControl/UIScrollView+BottomRefreshControl.h>
#import "AppUtil.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

const int PAGINACAO = 15;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [AppUtil adicionaLogo:self];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        [AppUtil removeTextoBotaoVoltar:self];
    }
    
    self.contextCache = [[NSCache alloc] init];
    self.accountStore = [[ACAccountStore alloc] init];
    self.arrMolduras = [NSMutableArray array];
    self.arrFotos = [NSMutableArray array];
    
    self.refreshTop = [UIRefreshControl new];
    [self.refreshTop addTarget:self action:@selector(carrega:) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshTop];
    
    self.refreshBottom = [UIRefreshControl new];
    [self.refreshBottom addTarget:self action:@selector(carregaMais) forControlEvents:UIControlEventValueChanged];
    self.collectionView.bottomRefreshControl = self.refreshBottom;
    
    UINib *nib = [UINib nibWithNibName:@"MolduraViewGrande" bundle: nil];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:@"CellMolduraGrande"];
    
    self.collectionView.contentOffset = CGPointMake(0, -self.refreshTop.frame.size.height);
    [self.refreshTop beginRefreshing];
    [self carrega:0.0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"sgFoto"]) {
        FotoViewController* controller = (FotoViewController*)segue.destinationViewController;
        controller.foto = self.foto;
    }
}

#pragma mark - Metodos de Classe

-(void)carregaMais
{
    [self carregaMolduras:0.0];
}

- (void)carrega:(float)delay
{
    self.recarrega = YES;
    [self carregaMolduras:delay];
}

- (void)atualizaColecao
{
    [self.refreshTop endRefreshing];
    [self.refreshBottom endRefreshing];
    [self.collectionView reloadData];
    if (self.recarrega)
    {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
    else
    {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.arrMolduras.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
    }
    self.recarrega = NO;
}

- (void)carregaMolduras:(float)delay
{
    PFQuery* query = [Moldura query];
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    query.limit = PAGINACAO;
    query.skip = self.recarrega? 0 : self.arrMolduras.count;
    [query whereKey:@"tipo" equalTo:@"free"];
    [query includeKey:@"tema"];
    [query includeKey:@"frase"];
    [query orderByAscending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            [self removeAviso];
            if ([PFUser currentUser])
            {
                [self carregaFotos:delay molduras:objects];
            }
            else
            {
                if (self.recarrega)
                {
                    [self.arrMolduras removeAllObjects];
                }
                [self.arrMolduras addObjectsFromArray:objects];
                [self atualizaColecao];
            }
        }
        else
        {
            [self adicionaAviso:NSLocalizedString(@"msg_moldura", nil) delay:delay];
        }
    }];
}

- (void)carregaFotos:(float)delay molduras:(NSArray*)molduras
{
    PFQuery* queryFoto = [Foto query];
    queryFoto.cachePolicy = kPFCachePolicyNetworkElseCache;
    [queryFoto whereKey:@"usuario" equalTo:[PFUser currentUser]];
    [queryFoto whereKey:@"moldura" containedIn:molduras];
    [queryFoto includeKey:@"moldura"];
    [queryFoto includeKey:@"moldura.tema"];
    [queryFoto includeKey:@"moldura.frase"];
    [queryFoto findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            [self removeAviso];
            if (self.recarrega)
            {
                [self.arrMolduras removeAllObjects];
                [self.arrFotos removeAllObjects];
            }
            [self.arrMolduras addObjectsFromArray:molduras];
            [self.arrFotos addObjectsFromArray:objects];
        }
        else
        {
            [self adicionaAviso:NSLocalizedString(@"msg_foto", nil) delay:delay];
        }
        [self atualizaColecao];
    }];
}

#pragma mark - Metodos IBAction

- (IBAction)mudaTamanho:(UISegmentedControl *)sender {
    self.fotosGrandes = !self.fotosGrandes;
    
    [self.collectionView reloadData];
}

- (IBAction)desloga:(UIBarButtonItem *)sender {
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: NSLocalizedString(@"msg_atencao", nil)
                          message: NSLocalizedString(@"msg_sair", nil)
                          delegate: self
                          cancelButtonTitle:NSLocalizedString(@"btn_cancelar", nil)
                          otherButtonTitles:NSLocalizedString(@"msg_sim", nil), nil];
    [alert show];
}

#pragma mark - Metodos AlertView Delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex)
    {
        [PFUser logOut];
        if (!self.abriuLogado)
        {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else
        {
            [self performSegueWithIdentifier:@"sgLogin" sender:nil];
        }
    }
}

#pragma mark - Metodos CollectionView FlowLayout

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size;
    if (self.fotosGrandes)
    {
        size = CGSizeMake(320, 384);
    }
    else
    {
        size = CGSizeMake(105, 126);
    }
    
    return size;
}

#pragma mark - Metodos CollectionView Datasource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.arrMolduras.count;
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        PerfilView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"CellPerfilHeader" forIndexPath:indexPath];
        headerView.user = PFUser.currentUser;
        reusableview = headerView;
    }
    
    return reusableview;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* cellIdentifier;
    
    if (self.fotosGrandes)
    {
        cellIdentifier = @"CellMolduraGrande";
    }
    else
    {
        cellIdentifier = @"CellMoldura";
    }
    
    MolduraView* cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    Moldura* moldura = [self.arrMolduras objectAtIndex:indexPath.item];
    
    cell.imgFoto.image = nil;
    
    if (self.arrFotos)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"moldura.objectId == %@", moldura.objectId];
        NSArray *filteredArray = [self.arrFotos filteredArrayUsingPredicate:predicate];
        
        if ([filteredArray count] > 0)
        {
            Foto* foto = [filteredArray objectAtIndex:0];

            UIImage* localImage = [self.contextCache objectForKey:foto.objectId];
            if (localImage)
            {
                cell.imgFoto.image = localImage;
            }
            else
            {
                [foto.arquivo getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    if (!error)
                    {
                        UIImage* image = [UIImage imageWithData:data];
                        [self.contextCache setObject:image forKey:foto.objectId];
                        cell.imgFoto.image = image;
                    }
                    else
                    {
                        [self adicionaAviso:[NSString stringWithFormat:@"%@ '%@'",NSLocalizedString(@"msg_foto_moldura", nil), moldura.titulo] delay:0.0];
                    }
                }];
            }
        }
    }
    
    if (self.fotosGrandes)
    {
        cell.lblTitulo.text = moldura.legenda;
    }
    else
    {
        cell.lblTitulo.text = moldura.titulo;
    }
    
    return cell;
}

#pragma mark - Metodos CollectionView Delegate

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Moldura* moldura = [self.arrMolduras objectAtIndex:indexPath.item];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"moldura.objectId == %@", moldura.objectId];
    NSArray *filteredArray = [self.arrFotos filteredArrayUsingPredicate:predicate];
    
    if ([filteredArray count] > 0)
    {
        self.foto = [filteredArray objectAtIndex:0];
    }
    else
    {
        self.foto = [Foto object];
        self.foto.moldura = moldura;
    }

    [self performSegueWithIdentifier:@"sgFoto" sender:nil];
}

@end
