//
//  CompartilhaViewController.m
//  LifePics
//
//  Created by Gabriel Moraes on 19/04/14.
//  Copyright (c) 2014 Gabriel Moraes. All rights reserved.
//

#import "CompartilhaViewController.h"
#import "HomeViewController.h"
#import "AppUtil.h"
#import "SocialView.h"

@interface CompartilhaViewController ()

@end

@implementation CompartilhaViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.onlyShare)
    {
        self.navigationItem.title = NSLocalizedString(@"tit_compartilhar", nil);
    }
    else
    {
        self.navigationItem.title = NSLocalizedString(@"tit_salvar", nil);
    }
    self.imgFoto.image = self.imagem;
    self.lblLegenda.text = self.moldura.legenda;
    
    self.arrSocial = [NSMutableArray arrayWithObjects:
//                      [Social socialNome:@"lifepics" option:FotoBarOptionLifePics],
                      [Social socialNome:@"facebook" option:FotoBarOptionFacebook],
                      [Social socialNome:@"twitter" option:FotoBarOptionTwitter],
//                      [Social socialNome:@"instagram" option:FotoBarOptionInstagram],
                      nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Metodos de Classe

-(void)usuarioLogou
{
    [AppUtil logadoSucesso];
    [self.collectionView reloadData];
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: NSLocalizedString(@"msg_bem_vindo", nil)
                          message: NSLocalizedString(@"msg_momentos", nil)
                          delegate: nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles: nil];
    [alert show];
}

#pragma mark - Metodos IBAction

- (IBAction)finaliza:(UIBarButtonItem *)sender {
    if ([PFUser currentUser])
    {
        NSMutableArray* arrOptions = [NSMutableArray array];
        
        for (int i = 0; i < self.arrSocial.count; i++) {
            SocialView* cell = (SocialView *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
            if (cell.swtAtivo.on)
            {
                [arrOptions addObject:[NSNumber numberWithInt:cell.social.option]];
            }
        }
        
        if (self.onlyShare)
        {
            if (!arrOptions.count)
            {
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle: NSLocalizedString(@"msg_verificar", nil)
                                      message: NSLocalizedString(@"msg_selecione", nil)
                                      delegate: nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
                [alert show];
                return;
            }
        }
        else
            [arrOptions addObject:[NSNumber numberWithInt:FotoBarOptionUpload]];
        
        if (!self.foto)
        {
            [AppUtil adicionaLoad:self];
            PFQuery* query = [Foto query];
            [query whereKey:@"moldura" equalTo:self.moldura];
            [query whereKey:@"usuario" equalTo:[PFUser currentUser]];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error)
                {
                    if (objects.count)
                    {
                        self.foto = objects[0];
                    }
                    else
                    {
                        self.foto = [Foto object];
                    }
                    
                    [((HomeViewController*)self.navigationController.viewControllers[0]) salvaImagem:[AppUtil imageWithImage:self.imagem scaledToSize:CGSizeMake(256, 256)] objeto:self.foto moldura:self.moldura comOpcoes:arrOptions];
                    
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }
                else
                {
                    [self adicionaAviso:NSLocalizedString(@"msg_postar", nil) delay:0.0];
                }
            }];
        }
        else
        {
            [((HomeViewController*)self.navigationController.viewControllers[0]) salvaImagem:[AppUtil imageWithImage:self.imagem scaledToSize:CGSizeMake(256, 256)] objeto:self.foto moldura:self.moldura comOpcoes:arrOptions];
            
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: NSLocalizedString(@"msg_atencao", nil)
                              message: NSLocalizedString(@"msg_publicar", nil)
                              delegate: self
                              cancelButtonTitle:NSLocalizedString(@"btn_cancelar", nil)
                              otherButtonTitles: NSLocalizedString(@"btn_logar", nil), nil];
        [alert show];
    }
}

#pragma mark - Metodos CollectionView FlowLayout

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(collectionView.frame.size.width, collectionView.frame.size.height/self.arrSocial.count);
}

#pragma mark - Metodos CollectionView Datasource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.arrSocial.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SocialView* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CellSocial" forIndexPath:indexPath];
    cell.social = [self.arrSocial objectAtIndex:indexPath.item];
    if (![PFUser currentUser])
    {
        cell.swtAtivo.enabled = NO;
    }
    else
    {
        cell.swtAtivo.enabled = YES;
    }
    
    return cell;
}

#pragma mark - Metodos AlertView Delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex)
    {
        [AppUtil adicionaLoad:self];
        self.btnFinaliza.enabled = NO;
        [PFFacebookUtils logInWithPermissions:@[@"publish_actions"] block:^(PFUser *user, NSError *error) {
            self.btnFinaliza.enabled = YES;
            self.navigationItem.rightBarButtonItem = nil;
            if (!user)
            {
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle: NSLocalizedString(@"msg_erro", nil)
                                      message: NSLocalizedString(@"msg_login", nil)
                                      delegate: nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles: nil];
                [alert show];
            }
            else
            {
                [self usuarioLogou];
            }
        }];
    }
}

@end
