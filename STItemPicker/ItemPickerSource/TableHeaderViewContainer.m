//
//  TableHeaderViewContainer.m
//  STItemPicker
//
//  Created by Simon Toens on 3/30/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "TableHeaderViewContainer.h"

@interface TableHeaderViewContainer : NSObject

@property (nonatomic, weak) IBOutlet TableHeaderView *tableHeaderView;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UILabel *label1;
@property (nonatomic, weak) IBOutlet UILabel *label2;
@property (nonatomic, weak) IBOutlet UILabel *label3;

@end

@implementation TableHeaderViewContainer

@synthesize label1, label2, label3;
@synthesize imageView;
@synthesize tableHeaderView;

@end

@implementation TableHeaderView

+ (TableHeaderView *)newTableHeaderView:(UIImage *)headerImage
{
    TableHeaderViewContainer *container = [[TableHeaderViewContainer alloc] init];
    [[NSBundle mainBundle] loadNibNamed:@"TableHeaderView" owner:container options:nil];
    [container.imageView setImage:headerImage];
    return container.tableHeaderView;
}

@end