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
#import "CompartilhaViewController.h"
#import "AppUtil.h"

@interface FotoViewController ()

@end

@implementation FotoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [AppUtil removeTextoBotaoVoltar:self];
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
        controller.moldura = self.moldura;
        controller.imagem = self.imagem;
        controller.foto = self.foto;
        controller.onlyShare = self.onlyShare;
    }
}

#pragma mark - Metodos IBAction

- (IBAction)sobe:(UIBarButtonItem *)sender {
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:@"Escolher foto" delegate:self cancelButtonTitle:@"Cancelar" destructiveButtonTitle:nil otherButtonTitles:@"Biblioteca", @"Câmera", nil];
    [actionSheet showInView:self.view];
}

- (IBAction)remove:(UIBarButtonItem *)sender {
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"Atenção"
                          message: @"Deseja realmente deletar essa imagem?"
                          delegate: self
                          cancelButtonTitle:@"Cancelar"
                          otherButtonTitles:@"Sim", nil];
    [alert show];
}

- (IBAction)compartilha:(UIBarButtonItem *)sender {
    self.onlyShare = YES;
    [self performSegueWithIdentifier:@"sgCompartilha" sender:nil];
}

#pragma mark - Metodos AlertView Delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex)
    {
        [AppUtil adicionaLoad:self];
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
}

#pragma mark - Metodos ActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex != 2)
    {
        UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
        imagePicker.delegate = self;
        imagePicker.allowsEditing = NO;
        imagePicker.navigationBar.barTintColor = [UIColor colorWithRed:13/255.0 green:145/255.0 blue:133/255.0 alpha:0.9];
        
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
    
    viewController.navigationController.navigationBar.tintColor = [UIColor whiteColor];
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
                self.imagem = editedImage;
                
                if (self.newMedia)
                    UIImageWriteToSavedPhotosAlbum(editedImage, self, @selector(image:finishedSavingWithError:contextInfo:), nil);
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

@end
