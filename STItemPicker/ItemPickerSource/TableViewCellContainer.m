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
    
    cell.textLabel.text = text;
    cell.imageView.image = image;
    cell.detailTextLabel.text = description;
    
    itemAttributes = itemAttributes ? itemAttributes : [ItemAttributes getDefaultItemAttributes];
    
    cell.userInteractionEnabled = itemAttributes.userInteractionEnabled;
    cell.textLabel.textColor = itemAttributes.textColor;
    cell.detailTextLabel.textColor = itemAttributes.descriptionTextColor;
        
    return cell;
}

@end