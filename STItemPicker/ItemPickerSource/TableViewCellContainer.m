// @author Simon Toens 03/31/13

#import "TableViewCellContainer.h"

@implementation TableViewCellContainer

+ (UITableViewCell *)newCellForTableView:(UITableView *)tableView 
                                   text:(NSString *)text
                                  image:(UIImage *)image 
                            description:(NSString *)description                         
                         itemAttributes:(ItemAttributes *)itemAttributes
{
    static NSString *cellReuseIdentifier = @"STItemPickerCell";
    UITableViewCellStyle cellStyle = description ? UITableViewCellStyleSubtitle : UITableViewCellStyleDefault;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:cellStyle reuseIdentifier:cellReuseIdentifier];
    }
    
    cell.userInteractionEnabled = YES;
    cell.textLabel.text = text;
    
    if (image)
    {
        cell.imageView.image = image;
    }
    if (description)
    {
        cell.detailTextLabel.text = description;        
    }
    
    if (itemAttributes)
    {
        cell.textLabel.textColor = itemAttributes.textColor;
        if (description)
        {
            cell.detailTextLabel.textColor = itemAttributes.textColor;
        }
        cell.userInteractionEnabled = itemAttributes.userInteractionEnabled;
    }
    
    return cell;
}

@end