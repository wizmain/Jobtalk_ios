//
//  SettingsEditViewController.m
//  JobTalk
//
//  Created by 김규완 on 13. 2. 20..
//  Copyright (c) 2013년 coelsoft. All rights reserved.
//

#import "SettingsEditViewController.h"
#import "Utils.h"
#import "SettingProperties.h"

@interface SettingsEditViewController ()

@property (nonatomic, retain) IBOutlet UITextField *textField;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) SettingProperties *settings;

@end

@implementation SettingsEditViewController

@synthesize textField, titleLabel;
@synthesize editProperty, editTitle, saveValue;

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
    
    
    self.titleLabel.text = self.editTitle;
    self.settings = [Utils settingProperties];
    if(self.settings == nil){
        _settings = [[SettingProperties alloc] init];
    }
    
    if([self.editProperty isEqualToString:@"1"]) {
        self.navigationItem.title = @"이름수정";
        self.textField.text = [self.settings userName];
    } else if([self.editProperty isEqualToString:@"2"]) {
        self.navigationItem.title = @"학교수정";
        self.textField.text = [self.settings schoolName];
    } else if([self.editProperty isEqualToString:@"3"]) {
        self.navigationItem.title = @"전공수정";
        self.textField.text = [self.settings majorName];
    } else if([self.editProperty isEqualToString:@"4"]) {
        self.navigationItem.title = @"학번수정";
        self.textField.text = [self.settings hakbun];
    }
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
    self.settings = nil;
}

- (void)dealloc
{
    
    [super dealloc];
}


- (IBAction)saveProperty:(id)sender {
    
    if([self.editProperty isEqualToString:@"1"]) {
        [self.settings setUserName:self.textField.text];
    } else if([self.editProperty isEqualToString:@"2"]) {
        [self.settings setSchoolName:self.textField.text];
    } else if([self.editProperty isEqualToString:@"3"]) {
        [self.settings setMajorName:self.textField.text];
    } else if([self.editProperty isEqualToString:@"4"]) {
        [self.settings setHakbun:self.textField.text];
    }

    NSLog(@"editProperty : %@, textField : %@, userName:%@", self.editProperty, self.textField.text,[self.settings userName]);
    [Utils saveSettingProperties:self.settings];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
