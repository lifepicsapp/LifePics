//
//  BuscaViewController.h
//  LifePics
//
//  Created by Gabriel Moraes on 26/05/14.
//  Copyright (c) 2014 Gabriel Moraes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Usuario.h"

@interface BuscaViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSArray* arrUsuarios;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
