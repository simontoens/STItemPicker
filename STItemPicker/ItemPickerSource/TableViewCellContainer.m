// @author Simon Toens 03/31/13

#import "TableViewCellContainer.h"

@interface TableViewCellContainer()

@property (nonatomic, weak) IBOutlet UITableViewCell *tableViewCell;

@end

@implementation TableViewCellContainer

@synthesize tableViewCell;

+ (UITableViewCell *)newTableViewCell
{
    TableViewCellContainer *container = [[TableViewCellContainer alloc] init];
    [[NSBundle mainBundle] loadNibNamed:@"TableViewCell" owner:container options:nil];
    return container.tableViewCell;
}

@end