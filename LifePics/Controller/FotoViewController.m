//
//  FotoViewController.m
//  LifePics
//
//  Created by Gabriel Moraes on 15/04/14.
//  Copyright (c) 2014 Gabriel Moraes. All rights reserved.
//

#import "FotoViewController.h"
#import <Parse/Parse.h>
#import "MolduraView.h"
#import "CropViewController.h"
#import "FotoViewController.h"
#import "HomeViewController.h"
#import "AppUtil.h"

@interface FotoViewController ()

@end

@implementation FotoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = self.moldura.titulo;
    self.lblLegenda.text = self.moldura.legenda;
    if (self.imagem)
    {
        self.imgFoto.image = self.imagem;
    }
    else
    {
        NSMutableArray *toolbarButtons = [self.toolbarItems mutableCopy];
        
        [toolbarButtons removeObject:self.btnCompartilhar];
        [toolbarButtons removeObject:self.btnRemover];
        [self setToolbarItems:toolbarButtons animated:YES];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Metodos IBAction

- (IBAction)sobe:(UIBarButtonItem *)sender {
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:@"Escolher foto" delegate:self cancelButtonTitle:@"Cancelar" destructiveButtonTitle:nil otherButtonTitles:@"Biblioteca", @"Câmera", nil];
    [actionSheet showInView:self.view];
}

- (IBAction)remove:(UIBarButtonItem *)sender {
    [self.foto deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            [((HomeViewController*)self.navigationController.viewControllers[0]) carrega];
            [self.navigationController popViewControllerAnimated:YES];
            UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle: @"Sucesso"
                                      message: @"Foto removida com sucesso!"
                                      delegate: nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
            [alert show];
        }
    }];
}

- (IBAction)compartilha:(UIBarButtonItem *)sender {
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    [params setObject:self.moldura.legenda forKey:@"message"];
    [params setObject:UIImageJPEGRepresentation(self.imagem, 90) forKey:@"source"];
    
    self.btnCompartilhar.enabled = NO;
    
    [FBRequestConnection startWithGraphPath:@"me/photos"
                                 parameters:params
                                 HTTPMethod:@"POST"
                          completionHandler:^(FBRequestConnection *connection,
                                              id result,
                                              NSError *error)
     {
         if (error)
         {
             UIAlertView *alert = [[UIAlertView alloc]
                                   initWithTitle: @"Erro"
                                   message: @"Erro ao compartilhar foto!"
                                   delegate: nil
                                   cancelButtonTitle:@"OK"
                                   otherButtonTitles:nil];
             [alert show];
         }
         else
         {
             UIAlertView *alert = [[UIAlertView alloc]
                                   initWithTitle: @"Sucesso"
                                   message: @"Foto compartilhada com sucesso!"
                                   delegate: nil
                                   cancelButtonTitle:@"OK"
                                   otherButtonTitles:nil];
             [alert show];
         }
         self.btnCompartilhar.enabled = YES;
     }];
}

#pragma mark - Metodos ActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex != 2)
    {
        UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
        imagePicker.delegate = self;
        imagePicker.allowsEditing = NO;
        
        if (buttonIndex == 0)
        {
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        else if (buttonIndex == 1)
        {
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            self.newMedia = YES;
        }
        
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

#pragma mark UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        
        CropViewController *imageEditor = [[CropViewController alloc] initWithNibName:@"CropView" bundle:nil];
        imageEditor.sourceImage = image;
        imageEditor.checkBounds = YES;
        imageEditor.rotateEnabled = YES;
        
        imageEditor.doneCallback = ^(UIImage *editedImage, BOOL canceled){
            
            if (!canceled)
            {
                NSData *imageData = UIImageJPEGRepresentation(editedImage, 0.05f);
                [self uploadImage:imageData];
                
                if (self.newMedia)
                    UIImageWriteToSavedPhotosAlbum(editedImage, self, @selector(image:finishedSavingWithError:contextInfo:), nil);
            }
            
            [picker dismissViewControllerAnimated:YES completion:^{
                [self dismissViewControllerAnimated:YES completion:nil];
            }];
            [picker setNavigationBarHidden:NO animated:YES];
        };
        
        [picker pushViewController:imageEditor animated:YES];
        [picker setNavigationBarHidden:YES animated:NO];
    }
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
        if (!error) {
            
            [self.HUD hide:YES];
            
            self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:self.HUD];
            
            self.HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
            self.HUD.mode = MBProgressHUDModeCustomView;
            
            self.HUD.delegate = self;
            
            Foto *foto = [Foto object];
            foto.arquivo = imageFile;
            
            PFUser *user = [PFUser currentUser];
            
            foto.ACL = [PFACL ACLWithUser:user];
            foto.usuario = user;
            foto.moldura = self.moldura;
            
            [foto saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error)
                {
                    [self.HUD show:YES];
                    NSLog(@"Foto salva com sucesso!");
                }
                else
                {
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
            }];
        }
        else
        {
            [self.HUD hide:YES];
            
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    } progressBlock:^(int percentDone) {
        self.HUD.progress = (float)percentDone/100;
    }];
}

-(void)image:(UIImage *)image finishedSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Erro"
                              message: @"Falha ao salvar imagem no albúm"
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark - Metodos HUD Delegate

- (void)hudWasHidden:(MBProgressHUD *)hud {
    [self.HUD removeFromSuperview];
    self.HUD = nil;
}

@end
