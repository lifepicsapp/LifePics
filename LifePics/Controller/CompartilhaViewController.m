//
//  CompartilhaViewController.m
//  LifePics
//
//  Created by Gabriel Moraes on 19/04/14.
//  Copyright (c) 2014 Gabriel Moraes. All rights reserved.
//

#import "CompartilhaViewController.h"
#import "UIViewController+QuedaConexao.h"
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
        self.navigationItem.title = @"Compartilhar";
    }
    else
    {
        self.navigationItem.title = @"Salvar";
    }
    self.imgFoto.image = self.imagem;
    self.lblLegenda.text = self.moldura.legenda;
    
    self.arrSocial = [NSMutableArray arrayWithObjects:
                      [Social social:@"facebook"],
                      [Social social:@"twitter"],
                      [Social social:@"instagram"],
                      nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Metodos IBAction

- (IBAction)finaliza:(UIBarButtonItem *)sender {
    self.btnFinaliza.enabled = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(encerraOperacoes:) name:@"OperacoesConcluidas" object:nil];
    if (self.onlyShare)
        [self compartilha];
    else
        [self uploadImage:UIImageJPEGRepresentation(self.imagem, 0.05f)];
}

#pragma mark - Metodos de Classe

- (void)encerraOperacoes:(NSNotification *)notification
{
    self.countFim++;
    if (self.countFim == self.countOperacao)
    {
        if (self.countFalha == self.countOperacao)
            [self adicionaAviso];
        else
        {
            [((HomeViewController*)self.navigationController.viewControllers[0]) carrega];
            [self.navigationController popToRootViewControllerAnimated:YES];
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: @"Sucesso"
                                  message: @"Foto compartilhada com sucesso!"
                                  delegate: nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            [alert show];
        }
        
        self.countFim = 0;
        self.countFalha = 0;
        self.countOperacao = 0;
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (void)compartilha
{
    [AppUtil adicionaLoad:self];
    for (int i = 0; i < self.arrSocial.count; i++) {
        SocialView* cell = (SocialView *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
        if (cell.swtAtivo.on)
        {
            self.countOperacao++;
            if (i==0)
                [self compartilhaFacebook];
            //                            else if (i==1)
            //
            //                            else
            //
        }
    }
    
    if (self.onlyShare)
    {
        if (!self.countOperacao)
        {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: @"Erro"
                                  message: @"Selecione ao menos um meio de compartilhamento!"
                                  delegate: nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            [alert show];
            
            self.btnFinaliza.enabled = YES;
            self.navigationItem.rightBarButtonItem = nil;
        }
    }
    else
    {
        [((HomeViewController*)self.navigationController.viewControllers[0]) carrega];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)compartilhaFacebook
{
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    [params setObject:[NSString stringWithFormat:URL_SHARE, self.moldura.legenda] forKey:@"message"];
    [params setObject:UIImageJPEGRepresentation(self.imagem, 90) forKey:@"source"];
    
    [FBRequestConnection startWithGraphPath:@"me/photos"
                                 parameters:params
                                 HTTPMethod:@"POST"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"OperacoesConcluidas" object:nil];
         if (error)
         {
             self.countFalha++;
         }
     }];
}

-(void)uploadImage:(NSData*)imageData
{
    PFFile *imageFile = [PFFile fileWithName:[[AppUtil escapeString:self.moldura.titulo] stringByAppendingString:@".jpg"] data:imageData];
    
    self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.HUD];
    
    self.HUD.delegate = self;
    self.HUD.mode = MBProgressHUDModeDeterminate;
    self.HUD.labelText = @"Carregando";
    
    [self.HUD show:YES];
    
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [self.HUD hide:YES];
        if (!error) {
            
            self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:self.HUD];
            
            self.HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
            self.HUD.mode = MBProgressHUDModeCustomView;
            
            self.HUD.delegate = self;
            [self.HUD show:YES];
            
            Foto *foto = [Foto object];
            foto.arquivo = imageFile;
            
            PFUser *user = [PFUser currentUser];
            
            foto.ACL = [PFACL ACLWithUser:user];
            foto.usuario = user;
            foto.moldura = self.moldura;
            
            [foto saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                self.btnFinaliza.enabled = YES;
                [self.HUD hide:YES];
                if (!error)
                {
                    [self compartilha];
                }
                else
                {
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
            }];
        }
        else
        {
            self.btnFinaliza.enabled = YES;
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    } progressBlock:^(int percentDone) {
        self.HUD.progress = (float)percentDone/100;
    }];
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
    
    return cell;
}

#pragma mark - Metodos HUD Delegate

- (void)hudWasHidden:(MBProgressHUD *)hud {
    [self.HUD removeFromSuperview];
    self.HUD = nil;
}

@end
