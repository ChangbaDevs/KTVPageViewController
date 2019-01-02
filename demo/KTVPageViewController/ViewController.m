//
//  ViewController.m
//  KTVPageViewController
//
//  Created by yaoyingtao on 2019/1/2.
//  Copyright © 2019 yaoyingtao. All rights reserved.
//

#import "ViewController.h"
#import "HeaderViewController.h"
#import "NoHeaderViewController.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController
#pragma mark - life circle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"KTVPageViewController";
    [self configTableView];
    
}

- (void)configTableView {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"demoIdentifier"];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"demoIdentifier"];
    cell.textLabel.text = (indexPath.row == 0) ? @"have header" : @"no header";
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        HeaderViewController *controller = [HeaderViewController new];
        [self.navigationController pushViewController:controller animated:YES];
    } else {
        NoHeaderViewController *controller = [NoHeaderViewController new];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

@end
