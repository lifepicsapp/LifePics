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
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0,0,85,35)];
    view.backgroundColor = [UIColor clearColor];
    UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,85,35)];
    iv.image = [UIImage imageNamed:@"logo-titulo"];
    [view addSubview:iv];
    self.navigationItem.titleView = view;
    
    self.cacheFotos = [[NSCache alloc] init];
    self.accountStore = [[ACAccountStore alloc] init];
    [AppUtil removeTextoBotaoVoltar:self];
    
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
        controller.imagem = [self.cacheFotos objectForKey:self.foto.objectId];
        controller.foto = self.foto;
        controller.moldura = self.moldura;
    }
}

#pragma mark - Metodos de Classe

- (void)carrega:(float)delay
{
    [AppUtil adicionaLoad:self];
    
    PFQuery* query = [Moldura query];
    [query whereKey:@"tipo" equalTo:@"free"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(atualiza:)];
        if (!error)
        {
            [AppUtil adicionaLoad:self];
            self.arrMolduras = objects;
            [self.collectionView reloadData];
            
            PFQuery* queryFoto = [Foto query];
            [queryFoto whereKey:@"usuario" equalTo:[PFUser currentUser]];
            [queryFoto findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(atualiza:)];
                if (!error)
                {
                    self.arrFotos = objects;
                    [self.collectionView reloadData];
                }
                else
                {
                    [self adicionaAviso:@"Erro ao baixar Fotos." delay:delay];
                }
            }];
        }
        else
        {
            [self adicionaAviso:@"Erro ao carregar Molduras." delay:delay];
        }
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
                          initWithTitle: @"Atenção"
                          message: @"Deseja realmente sair?"
                          delegate: self
                          cancelButtonTitle:@"Cancelar"
                          otherButtonTitles:@"Sim", nil];
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
            [foto fetchIfNeeded];
            
            UIImage* cacheImage = [self.cacheFotos objectForKey:foto.objectId];
            if (cacheImage) {
                cell.imgFoto.image = cacheImage;
            }
            else
            {
                [foto.arquivo getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    if (!error) {
                        UIImage* image = [UIImage imageWithData:data];
                        [self.cacheFotos setObject:image forKey:foto.objectId];
                        cell.imgFoto.image = image;
                    }
                    else
                    {
                        [self adicionaAviso:[NSString stringWithFormat:@"Erro ao carregar imagem da Moldura '%@'", moldura.titulo] delay:0.0];
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
    self.moldura = [self.arrMolduras objectAtIndex:indexPath.item];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"moldura.objectId == %@", self.moldura.objectId];
    NSArray *filteredArray = [self.arrFotos filteredArrayUsingPredicate:predicate];
    
    if ([filteredArray count] > 0)
    {
        self.foto = [filteredArray objectAtIndex:0];
    }
    else
    {
        self.foto = nil;
    }

    [self performSegueWithIdentifier:@"sgFoto" sender:nil];
}

@end
