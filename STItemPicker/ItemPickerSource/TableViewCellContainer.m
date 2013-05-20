// @author Simon Toens 03/31/13

#import "TableViewCellContainer.h"

@interface TableViewCellContainer()

+ (ItemPickerCell *)newTableViewCellWithNibName:(NSString *)nibName;

@property (nonatomic, weak) IBOutlet ItemPickerCell *cell;

@end

@implementation TableViewCellContainer

@synthesize cell;

+ (ItemPickerCell *)newCellForTableView:(UITableView *)tableView image:(UIImage *)image description:(NSString *)description;
{
    NSString *cellIdentifier = @"ItemPickerCell";
    if (image)
    {
        cellIdentifier = [NSString stringWithFormat:@"%@Image", cellIdentifier];
    }
    if (description)
    {
        cellIdentifier = [NSString stringWithFormat:@"%@Description", cellIdentifier];
    }
    
    ItemPickerCell *itemPickerCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    if (!itemPickerCell)
    {
        itemPickerCell = [TableViewCellContainer newTableViewCellWithNibName:cellIdentifier];
    }
    
    if (image)
    {
        itemPickerCell.iview.image = image;
    }
    if (description)
    {
        itemPickerCell.description.text = description;
    }
    
    return itemPickerCell;
}

+ (ItemPickerCell *)newTableViewCellWithNibName:(NSString *)nibName
{
    TableViewCellContainer *container = [[TableViewCellContainer alloc] init];
    [[NSBundle mainBundle] loadNibNamed:nibName owner:container options:nil];
    return container.cell;    
}

@end