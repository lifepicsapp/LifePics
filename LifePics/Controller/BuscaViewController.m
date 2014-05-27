//
//  BuscaViewController.m
//  LifePics
//
//  Created by Gabriel Moraes on 26/05/14.
//  Copyright (c) 2014 Gabriel Moraes. All rights reserved.
//

#import "BuscaViewController.h"
#import "AppUtil.h"
#import <Parse/Parse.h>

@interface BuscaViewController ()

@end

@implementation BuscaViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [AppUtil adicionaLogo:self];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        [AppUtil removeTextoBotaoVoltar:self];
    }
    
    PFQuery* query = [PFUser query];
    [query whereKeyExists:@"login"];
    [query whereKey:@"objectId" notEqualTo:PFUser.currentUser.objectId];
    query.limit = 8;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.arrUsuarios = objects;
        [self.tableView reloadData];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arrUsuarios.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellUsuario";
    
    PFUser *user = [self.arrUsuarios objectAtIndex:indexPath.item];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.textLabel.text = [user valueForKey:@"login"];
    return cell;
}

@end
