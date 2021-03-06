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
#import "AlbumViewController.h"
#import "CompartilhaViewController.h"
#import "AppUtil.h"

@interface FotoViewController ()

@end

@implementation FotoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        [AppUtil removeTextoBotaoVoltar:self];
    }
    self.navigationItem.title = self.foto.moldura.titulo;
    self.lblLegenda.text = self.foto.moldura.legenda;
    if (self.foto.arquivo)
    {
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
    }
    else
    {
        self.btnCompartilhar.enabled = NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"sgCompartilha"])
    {
        CompartilhaViewController* controller = (CompartilhaViewController*)segue.destinationViewController;
        controller.foto = self.foto;
        controller.onlyShare = self.onlyShare;
        self.onlyShare = NO;
        self.newMedia = NO;
    }
}

#pragma mark - Metodos de Classe

- (void)escolheFoto {
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"msg_escolher", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"btn_cancelar", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"btn_biblioteca", nil), NSLocalizedString(@"btn_camera", nil), nil];
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
}

#pragma mark - Metodos IBAction

- (IBAction)pressImage:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        if (self.foto.arquivo)
        {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: NSLocalizedString(@"msg_atencao", nil)
                                  message: NSLocalizedString(@"msg_deletar", nil)
                                  delegate: self
                                  cancelButtonTitle:NSLocalizedString(@"btn_cancelar", nil)
                                  otherButtonTitles:NSLocalizedString(@"msg_sim", nil), nil];
            [alert show];
        }
    }
}

- (IBAction)compartilha:(UIBarButtonItem *)sender {
    self.onlyShare = YES;
    [self performSegueWithIdentifier:@"sgCompartilha" sender:nil];
}

- (IBAction)tapImage:(UITapGestureRecognizer *)sender {
    [self escolheFoto];
}

#pragma mark - Metodos AlertView Delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex)
    {
        [AppUtil adicionaLoad:self];
        [self.foto deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                AlbumViewController* home = (AlbumViewController*)self.navigationController.viewControllers[0];
                [home carrega:0.0];
                [self.navigationController popViewControllerAnimated:YES];
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle: NSLocalizedString(@"msg_sucesso", nil)
                                      message: NSLocalizedString(@"msg_deletada", nil)
                                      delegate: nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
                [alert show];
            }
            else
            {
                self.navigationItem.rightBarButtonItem = nil;
                [self adicionaAviso:NSLocalizedString(@"msg_erro_deletar", nil) delay:0.0];
            }
        }];
    }
}

#pragma mark - Metodos ActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex != 2)
    {
        UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
        imagePicker.delegate = self;
        imagePicker.allowsEditing = NO;
        
        UIColor* color = [UIColor colorWithRed:13/255.0 green:145/255.0 blue:133/255.0 alpha:0.1];
        UIColor* colorItems = [UIColor whiteColor];
        
        imagePicker.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  colorItems,NSForegroundColorAttributeName,
                                                  colorItems,NSBackgroundColorAttributeName,nil];
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0)
        {
            imagePicker.navigationBar.tintColor = color;
            imagePicker.navigationBar.backgroundColor = colorItems;
        }
        else
        {
            imagePicker.navigationBar.barTintColor = color;
            imagePicker.navigationBar.tintColor = colorItems;
        }
        
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

#pragma mark - Métodos NavigationController Delegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    viewController.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName,
                                    [UIColor whiteColor], NSBackgroundColorAttributeName,
                                                                             nil];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0)
    {
        viewController.navigationController.navigationBar.backgroundColor = [UIColor colorWithRed:13/255.0 green:145/255.0 blue:133/255.0 alpha:0.1];
    }
    else
    {
        viewController.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    }
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
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
                UIImage* resizedImage = [AppUtil imageWithImage:editedImage scaledToSize:CGSizeMake(256, 256)];
                NSData* imageData = UIImageJPEGRepresentation(resizedImage, 1.0f);
                NSString* imageName = [[AppUtil escapeString:self.foto.moldura.titulo] stringByAppendingString:@".jpg"];
                
                self.foto.arquivo = [PFFile fileWithName:imageName data:imageData];
                
                if (self.newMedia)
                {
                    UIImageWriteToSavedPhotosAlbum(editedImage, self, @selector(image:finishedSavingWithError:contextInfo:), nil);
                }
            }
            
            [picker dismissViewControllerAnimated:YES completion:^{
                if (!canceled)
                    [self performSegueWithIdentifier:@"sgCompartilha" sender:nil];
            }];
            [picker setNavigationBarHidden:NO animated:YES];
        };
        
        [picker pushViewController:imageEditor animated:YES];
        [picker setNavigationBarHidden:YES animated:NO];
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    self.newMedia = NO;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)image:(UIImage *)image finishedSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        [self adicionaAviso:NSLocalizedString(@"msg_album", nil) delay:0.0];
    }
}

@end
