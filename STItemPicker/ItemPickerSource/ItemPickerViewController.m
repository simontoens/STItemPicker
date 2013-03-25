// @author Simon Toens 12/14/12

#import "ItemPickerViewController.h"
#import "TableSectionHandler.h"

@interface ItemPickerViewController()
@property(nonatomic, strong) id<ItemPickerDataSource> dataSource;
@property(nonatomic, strong) TableSectionHandler *tableSectionHandler;
@end

@implementation ItemPickerViewController

@synthesize itemPickerDelegate;
@synthesize dataSource = _dataSource;
@synthesize tableSectionHandler;

- (id)initWithDataSource:(id<ItemPickerDataSource>)dataSource {
    if (self = [super initWithNibName:@"ItemPickerViewController" bundle:nil]) 
    {
        _dataSource = dataSource;
    }
    return self;
}

- (void)viewDidLoad 
{    
    [super viewDidLoad];
    self.title = self.dataSource.header;
    
    self.tableSectionHandler = [[TableSectionHandler alloc] initWithItems:self.dataSource.items 
                                                            alreadySorted:self.dataSource.itemsAlreadySorted];
    
    self.tableSectionHandler.sectionsEnabled = self.dataSource.sectionsEnabled;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return [self.tableSectionHandler.sections count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
    return [self.tableSectionHandler.sections objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    NSString *s = [self.tableSectionHandler.sections objectAtIndex:section];
   return [[self.tableSectionHandler.sectionToNumberOfItems objectForKey:s] intValue];
} 

- (int)getItemRow:(NSIndexPath *)indexPath
{
    int row = 0;
    for (int i = 0; i < indexPath.section; i++) 
    {
        NSString *s = [self.tableSectionHandler.sections objectAtIndex:i];
        row += [[self.tableSectionHandler.sectionToNumberOfItems objectForKey:s] intValue];
    }
    return row + indexPath.row;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{ 
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) 
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.accessoryType = self.dataSource.hasDetailDataSource ? 
        UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
        
    int row = [self getItemRow:indexPath];
    cell.textLabel.text = [self.tableSectionHandler.items objectAtIndex:row];
    return cell; 
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    NSString *selection = [self.tableSectionHandler.items objectAtIndex:[self getItemRow:indexPath]];
    id<ItemPickerDataSource> nextDataSource = [self.dataSource getNextDataSource:selection];
    if (nextDataSource) {
        ItemPickerViewController *controller = [[ItemPickerViewController alloc] initWithDataSource:nextDataSource];
        controller.itemPickerDelegate = self.itemPickerDelegate;
        [self.navigationController pushViewController:controller animated:YES];
    } else {
        [self.itemPickerDelegate pickedItem:selection];
    }
}

@end