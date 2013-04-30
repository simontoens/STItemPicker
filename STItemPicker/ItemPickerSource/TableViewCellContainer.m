// @author Simon Toens 03/31/13

#import "TableViewCellContainer.h"

@interface TableViewCellContainer()

+ (TableViewCell *)newTableViewCellWithNibName:(NSString *)nibName;

@property (nonatomic, weak) IBOutlet TableViewCell *cell;

@end

@implementation TableViewCellContainer

@synthesize cell;

+ (TableViewCell *)newPlainTableViewCell
{
    return [TableViewCellContainer newTableViewCellWithNibName:@"PlainTableViewCell"];
}

+ (NSString *)plainTableViewCellIdentifier
{
    return @"STItemPickerPlainCell";
}

+ (TableViewCell *)newImageTableViewCell
{
    return [TableViewCellContainer newTableViewCellWithNibName:@"ImageTableViewCell"];
}

+ (NSString *)imageTableViewCellIdentifier
{
    return @"STItemPickerImageCell";
}

+ (TableViewCell *)newTableViewCellWithNibName:(NSString *)nibName
{
    TableViewCellContainer *container = [[TableViewCellContainer alloc] init];
    [[NSBundle mainBundle] loadNibNamed:nibName owner:container options:nil];
    return container.cell;    
}

@end