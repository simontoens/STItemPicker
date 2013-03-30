// @author Simon Toens 12/14/12

#import "ItemPickerViewController.h"
#import "Preconditions.h"
#import "TableSectionHandler.h"

@interface ItemPickerViewController()
- (void)configureHeaderView;
- (NSInteger)getItemRow:(NSIndexPath *)indexPath;
@property(nonatomic, strong) id<ItemPickerDataSource> dataSource;
@property(nonatomic, strong) TableSectionHandler *tableSectionHandler;
@end

@implementation ItemPickerViewController

@synthesize itemPickerDelegate;
@synthesize dataSource = _dataSource;
@synthesize tableSectionHandler = _tableSectionHandler;

- (id)initWithDataSource:(id<ItemPickerDataSource>)dataSource 
{
    if (self = [super initWithNibName:@"ItemPickerViewController" bundle:nil]) 
    {
        [Preconditions assertNotNil:dataSource];
        _dataSource = dataSource;
        _tableSectionHandler = [[TableSectionHandler alloc] initWithItems:_dataSource.items 
                                                            alreadySorted:_dataSource.itemsAlreadySorted];
        _tableSectionHandler.sectionsEnabled = _dataSource.sectionsEnabled;
        self.title = _dataSource.title;
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self configureHeaderView];
}

#pragma mark - UITableView methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    NSString *selection = [self.tableSectionHandler.items objectAtIndex:[self getItemRow:indexPath]];
    id<ItemPickerDataSource> nextDataSource = [self.dataSource getNextDataSource:selection];
    if (nextDataSource) 
    {
        ItemPickerViewController *controller = [[ItemPickerViewController alloc] initWithDataSource:nextDataSource];
        controller.itemPickerDelegate = self.itemPickerDelegate;
        [self.navigationController pushViewController:controller animated:YES];
    } 
    else 
    {
        [self.itemPickerDelegate pickedItem:selection atIndex:[self getItemRow:indexPath]];
    }
}

#pragma mark - UITableViewDataSource protocol

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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{ 
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) 
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
        
    int row = [self getItemRow:indexPath];
    cell.textLabel.text = [self.tableSectionHandler.items objectAtIndex:row];
    return cell; 
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.tableSectionHandler.sections;
}

#pragma mark - Private methods

- (void)configureHeaderView {
    UIImage *headerImage = self.dataSource.headerImage;
    if (headerImage) 
    {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.width, 0, 110)];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 100, 100)];
        [imageView setImage:headerImage];
        [headerView addSubview:imageView];
        self.tableView.tableHeaderView = headerView;
    }    
}

- (NSInteger)getItemRow:(NSIndexPath *)indexPath
{
    NSInteger row = 0;
    for (int i = 0; i < indexPath.section; i++) 
    {
        NSString *s = [self.tableSectionHandler.sections objectAtIndex:i];
        row += [[self.tableSectionHandler.sectionToNumberOfItems objectForKey:s] intValue];
    }
    return row + indexPath.row;
}

@end