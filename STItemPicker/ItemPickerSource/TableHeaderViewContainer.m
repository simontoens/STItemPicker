// @author Simon Toens 03/30/13

#import "TableHeaderViewContainer.h"
#import "UIImageView+Reflection.h"

@interface TableHeaderViewContainer()

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIImageView *reflectedImageView;

@end

@implementation TableHeaderViewContainer

@synthesize boldLabel, label, smallerLabel, smallestLabel;
@synthesize imageView, reflectedImageView;
@synthesize tableHeaderView;

+ (TableHeaderViewContainer *)newTableHeaderViewWithImage:(UIImage *)image
{
    TableHeaderViewContainer *container = [[TableHeaderViewContainer alloc] init];
    [[NSBundle mainBundle] loadNibNamed:@"TableHeaderView" owner:container options:nil];
    if (image) 
    {
        [container.imageView setImage:image];
        [container.reflectedImageView setImage:[container.imageView 
                                                reflectedImageWithHeight:container.reflectedImageView.bounds.size.height]];
    }
    container.boldLabel.text = @"";
    container.label.text = @"";
    container.smallerLabel.text = @"";
    container.smallestLabel.text = @"";
    return container;
}

@end