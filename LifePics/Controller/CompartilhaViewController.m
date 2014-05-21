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
#import "UITextField+MaxLength.h"

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
    
    [self.foto.arquivo getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error)
        {
            self.imgFoto.image = [UIImage imageWithData:data];
        }
        else
        {
            [self adicionaAviso:[NSString stringWithFormat:@"%@ '%@'",NSLocalizedString(@"msg_foto_moldura", nil), self.foto.moldura.titulo] delay:0.0];
        }
    }];
    self.lblLegenda.text = self.foto.moldura.legenda;
    
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

-(void)enviaComLegenda:(NSString*)legenda
{
    HomeViewController* home = (HomeViewController*)self.navigationController.viewControllers[0];
    [home salva:self.foto compartilha:UIImageJPEGRepresentation([AppUtil imageWithView:self.vwCompartilha], 1.0f) opcoes:self.arrOptions legenda:legenda];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)alertaLegenda {
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:NSLocalizedString(@"msg_legenda", nil)
                          message:nil
                          delegate: self
                          cancelButtonTitle:NSLocalizedString(@"btn_cancelar", nil)
                          otherButtonTitles:NSLocalizedString(@"btn_concluido", nil), nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert textFieldAtIndex:0].maxLength = [NSNumber numberWithInt:90];
    [alert show];
}

#pragma mark - Metodos IBAction

- (IBAction)finaliza:(UIBarButtonItem *)sender {
    if ([PFUser currentUser])
    {
        self.arrOptions = [NSMutableArray array];
        
        for (int i = 0; i < self.arrSocial.count; i++) {
            SocialView* cell = (SocialView *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
            if (cell.swtAtivo.on)
            {
                [self.arrOptions addObject:[NSNumber numberWithInt:cell.social.option]];
            }
        }
        
        if (self.onlyShare)
        {
            if (!self.arrOptions.count)
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
        {
            [self.arrOptions addObject:[NSNumber numberWithInt:FotoBarOptionUpload]];
        }
        
        if (self.arrOptions.count > 1)
        {
            [self alertaLegenda];
        }
        else if(![self.arrOptions containsObject:FotoBarOptionUpload])
        {
            [self alertaLegenda];
        }
        else
        {
            [self enviaComLegenda:nil];
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
    return CGSizeMake(collectionView.frame.size.width/self.arrSocial.count, collectionView.frame.size.height);
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
    cell.swtAtivo.enabled = [PFUser currentUser] != nil;
    
    return cell;
}

#pragma mark - Metodos AlertView Delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex)
    {
        if (alertView.alertViewStyle == UIAlertViewStylePlainTextInput)
        {
            UITextField* txtComentario = [alertView textFieldAtIndex:0];
            [self enviaComLegenda:[NSString stringWithFormat:URL_SHARE, txtComentario.text]];
        }
        else
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
}

@end
