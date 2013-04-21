// @author Simon Toens 03/31/13

#import "TableViewCellContainer.h"

@interface TableViewCellContainer()

@property (nonatomic, weak) IBOutlet TableViewCell *cell;

@end

@implementation TableViewCellContainer

@synthesize cell;

+ (TableViewCell *)newTableViewCell
{
    TableViewCellContainer *container = [[TableViewCellContainer alloc] init];
    [[NSBundle mainBundle] loadNibNamed:@"TableViewCellWithImage" owner:container options:nil];
    return container.cell;
}

@end