// @author Simon Toens 10/27/13

#import "ItemPickerHeader.h"
#import "ItemPickerSelection.h"
#import "TableHeaderView.h"
#import "UIImageView+Reflection.h"

@interface TableHeaderView()

@property (nonatomic, weak) IBOutlet UILabel *boldLabel;
@property (nonatomic, weak) IBOutlet UILabel *label;
@property (nonatomic, weak) IBOutlet UILabel *smallerLabel;
@property (nonatomic, weak) IBOutlet UILabel *smallestLabel;

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIImageView *reflectedImageView;

@end

@implementation TableHeaderView

+ (UIView *)initWithHeader:(ItemPickerHeader *)header selectionStack:(Stack *)selectionStack dataSourceAccess:(DataSourceAccess *)dataSourceAccess
{
    TableHeaderView *view = [[[NSBundle mainBundle] loadNibNamed:@"TableHeaderView" owner:nil options:nil] firstObject];

    if (header.image)
    {
        [view.imageView setImage:header.image];
        [view.reflectedImageView setImage:[view.imageView reflectedImageWithHeight:view.reflectedImageView.bounds.size.height]];
    }
    
    view.boldLabel.text = header.boldLabel ? header.boldLabel : nil;
    view.label.text = header.label ? header.label : nil;
    view.smallerLabel.text = header.smallerLabel ? header.smallerLabel : nil;
    view.smallestLabel.text = header.smallestLabel ? header.smallestLabel : nil;
    
    if (header.defaultNilLabels)
    {
        NSArray *contexts = [selectionStack allObjects];
        view.boldLabel.text = [self getContextFrom:contexts atOffsetFromEnd:1].selectedItem;
        view.label.text = [self getContextFrom:contexts atOffsetFromEnd:0].selectedItem;
        view.smallerLabel.text = [NSString stringWithFormat:@"%i %@", [dataSourceAccess getDataSourceItemCount], [dataSourceAccess getTitle]];        
    }
    
    return view;
}

+ (ItemPickerSelection *)getContextFrom:(NSArray *)contexts atOffsetFromEnd:(NSUInteger)offset
{
    return [contexts count] > offset ? [contexts objectAtIndex:[contexts count] - 1 - offset] : nil;
}

@end