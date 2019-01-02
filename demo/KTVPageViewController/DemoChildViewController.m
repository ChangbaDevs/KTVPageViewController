//
//  DemoChildViewController.m
//  KTVPageViewController
//
//  Created by yaoyingtao on 2019/1/2.
//  Copyright © 2019 yaoyingtao. All rights reserved.
//

#import "DemoChildViewController.h"

@interface DemoChildViewController () <UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation DemoChildViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configTableView];
}

- (void)configTableView {
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"demoIdentifier"];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"demoIdentifier"];
    cell.textLabel.text = [NSString stringWithFormat:@"index:%ld-row:%ld", self.index,indexPath.row];
    return cell;
}


@end
