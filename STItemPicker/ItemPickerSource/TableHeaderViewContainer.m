// @author Simon Toens 03/30/13

#import "TableHeaderViewContainer.h"
#import "UIImageView+Reflection.h"

@interface TableHeaderViewContainer()

@property (nonatomic, weak) IBOutlet UIView *tableHeaderView;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIImageView *reflectedImageView;
@property (nonatomic, weak) IBOutlet UILabel *label1;
@property (nonatomic, weak) IBOutlet UILabel *label2;
@property (nonatomic, weak) IBOutlet UILabel *label3;

@end

@implementation TableHeaderViewContainer

@synthesize label1, label2, label3;
@synthesize imageView, reflectedImageView;
@synthesize tableHeaderView;

+ (UIView *)newTableHeaderView:(UIImage *)image 
                        label1:(NSString *)l1 
                        label2:(NSString *)l2
                        label3:(NSString *)l3
{
    TableHeaderViewContainer *container = [[TableHeaderViewContainer alloc] init];
    [[NSBundle mainBundle] loadNibNamed:@"TableHeaderView" owner:container options:nil];
    [container.imageView setImage:image];
    [container.label1 setText:l1];
    [container.label2 setText:l2];
    [container.label3 setText:l3];
    [container.reflectedImageView setImage:[container.imageView reflectedImageWithHeight:container.reflectedImageView.bounds.size.height]];
    return container.tableHeaderView;
}

@end