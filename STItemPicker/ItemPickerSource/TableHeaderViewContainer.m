// @author Simon Toens 03/30/13

#import "TableHeaderViewContainer.h"

@interface TableHeaderViewContainer()

@property (nonatomic, weak) IBOutlet UIView *tableHeaderView;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UILabel *label1;
@property (nonatomic, weak) IBOutlet UILabel *label2;

@end

@implementation TableHeaderViewContainer

@synthesize label1, label2;
@synthesize imageView;
@synthesize tableHeaderView;

+ (UIView *)newTableHeaderView:(UIImage *)image label1:(NSString *)l1 label2:(NSString *)l2
{
    TableHeaderViewContainer *container = [[TableHeaderViewContainer alloc] init];
    [[NSBundle mainBundle] loadNibNamed:@"TableHeaderView" owner:container options:nil];
    [container.imageView setImage:image];
    [container.label1 setText:l1];
    [container.label2 setText:l2];
    return container.tableHeaderView;
}

@end