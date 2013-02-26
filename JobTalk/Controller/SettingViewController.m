//
//  SettingViewController.m
//  JobTalk
//
//  Created by 김규완 on 13. 1. 8..
//  Copyright (c) 2013년 coelsoft. All rights reserved.
//

#import "SettingViewController.h"
#import "SettingProperties.h"
#import "Utils.h"
#import "SettingsEditViewController.h"

#define kValueTextColor             0x0b6ad4
#define kSection1Title      @"이름"
#define kSection2Title      @"학교"
#define kSection3Title      @"전공"
#define kSection4Title      @"학번"


@interface SettingViewController ()

@property (nonatomic, retain) IBOutlet UITableView *table;
@property (nonatomic, retain) SettingProperties *settings;

@end

@implementation SettingViewController

@synthesize table;
@synthesize settings;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"설정";
    self.settings = [Utils settingProperties];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    self.settings = nil;
    self.settings = [Utils settingProperties];
    [self.table reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.table = nil;
    self.settings = nil;
}

- (void)dealloc
{
    [table release];
    [super dealloc];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(section == 0) {//이름
        return 1;
    } else if(section == 1) {//학교
        return 1;
    } else if(section == 2) {//전공
        return 1;
    } else if(section == 3) {//학번
        return 1;
    } else {
        return 1;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 42;
    /*
     if([indexPath section] == 0) {//과제명
     return 42;
     } else if([indexPath section] == 1) {//
     return 42;
     } else if([indexPath section] == 2) {//
     return 42;
     } else if ([indexPath section] == 3) {
     return 85;
     } else {
     return 42;
     }
     */
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if(section == 0) {
        return kSection1Title;
    } else if(section == 1) {
        return kSection2Title;
    } else if(section == 2) {
        return kSection3Title;
    } else if (section == 3) {
        return kSection4Title;
    } else {
        return @"";
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}


- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)] autorelease];
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(10, 3, tableView.bounds.size.width - 10, 18)] autorelease];
    //label.textColor = UIColorFromRGB(kValueTextColor);
    if(section == 0) {
        label.text = kSection1Title;
    } else if(section == 1) {
        label.text = kSection2Title;
    } else if(section == 2) {
        label.text = kSection3Title;
    } else if (section == 3) {
        label.text = kSection4Title;
    }
    
    label.backgroundColor = [UIColor clearColor];
    [headerView addSubview:label];
    
    //if (section == 0)
    //    [headerView setBackgroundColor:[UIColor redColor]];
    //else
    //    [headerView setBackgroundColor:[UIColor clearColor]];
    
    return headerView;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	// TODO: Double-check for performance drain later
	
    static NSString *normalCellIdentifier = @"SettingsCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:normalCellIdentifier];
    
    if(cell == nil){
        
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
									   reuseIdentifier:normalCellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryNone;
        
    }
    
    
	if ([indexPath section] == 0) {
		cell.textLabel.text = [self.settings userName];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if([indexPath section] == 1) {
        cell.textLabel.text = [self.settings schoolName];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
	} else if([indexPath section] == 2){
        cell.textLabel.text = [self.settings majorName];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    } else if([indexPath section] == 3) {
        cell.textLabel.text = [self.settings hakbun];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
	}
    
	return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
    SettingsEditViewController *settingsEdit = [[SettingsEditViewController alloc] initWithNibName:@"SettingsEditViewController" bundle:nil];
    
    if([indexPath section] == 0){
        settingsEdit.editTitle = kSection1Title;
        settingsEdit.editProperty = @"1";
    } else if([indexPath section] == 1) {
        settingsEdit.editTitle = kSection2Title;
        settingsEdit.editProperty = @"2";
    } else if([indexPath section] == 2) {
        settingsEdit.editTitle = kSection3Title;
        settingsEdit.editProperty = @"3";
    } else if([indexPath section] == 3) {
        settingsEdit.editTitle = kSection4Title;
        settingsEdit.editProperty = @"4";
    }
    
    [self.navigationController pushViewController:settingsEdit animated:YES];
    [settingsEdit release];
    
}

@end
