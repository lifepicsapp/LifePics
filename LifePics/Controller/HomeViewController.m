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
#import "FotoViewController.h"
#import "AppUtil.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [AppUtil adicionaLogo:self];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        [AppUtil removeTextoBotaoVoltar:self];
    }
    
    self.contextCache = [[NSCache alloc] init];
    self.accountStore = [[ACAccountStore alloc] init];
    
    UINib *nib = [UINib nibWithNibName:@"MolduraViewGrande" bundle: nil];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:@"CellMolduraGrande"];
    
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

- (void)carrega:(float)delay
{
    [AppUtil adicionaLoad:self];
    
    PFQuery* query = [Moldura query];
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    [query whereKey:@"tipo" equalTo:@"free"];
    [query includeKey:@"tema"];
    [query includeKey:@"frase"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(atualiza:)];
        if (!error)
        {
            [self removeAviso];
            self.arrMolduras = objects;
            if ([PFUser currentUser])
            {
                [self carregaFotos:delay];
            }
            else
            {
                [self.collectionView reloadData];
            }
        }
        else
        {
            [self adicionaAviso:NSLocalizedString(@"msg_moldura", nil) delay:delay];
        }
    }];
}

- (void)carregaFotos:(float)delay
{
    [AppUtil adicionaLoad:self];
    PFQuery* queryFoto = [Foto query];
    queryFoto.cachePolicy = kPFCachePolicyNetworkElseCache;
    [queryFoto whereKey:@"usuario" equalTo:[PFUser currentUser]];
    [queryFoto includeKey:@"moldura"];
    [queryFoto includeKey:@"moldura.tema"];
    [queryFoto includeKey:@"moldura.frase"];
    [queryFoto findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(atualiza:)];
        if (!error)
        {
            [self removeAviso];
            self.arrFotos = objects;
        }
        else
        {
            [self adicionaAviso:NSLocalizedString(@"msg_foto", nil) delay:delay];
        }
        [self.collectionView reloadData];
    }];
}

#pragma mark - Metodos IBAction

- (IBAction)mudaTamanho:(UIBarButtonItem *)sender {
    self.fotosGrandes = !self.fotosGrandes;
    if (self.fotosGrandes)
    {
        sender.image = [UIImage imageNamed:@"grid"];
    }
    else
    {
        sender.image = [UIImage imageNamed:@"icon-polaroid"];
    }
    
    [self.collectionView reloadData];
}

- (IBAction)atualiza:(UIBarButtonItem *)sender
{
    [self carrega:0.0];
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
