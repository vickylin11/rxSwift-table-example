# rxSwift-table-example
This is a simple to-do-list app using rxSwift for starter

## Introduction
This project is a very simple app with an example of to-do-list for rxSwift starter, which used Swift 11 and was rewritten using rxSwift and rxCocoa. Some of the swift codes was kept and commented in the project in order to know how they changed to rxSwift.

## Features
The project allows user to create new task by clicking the add button;
User is able to delete the task by swiping the task and click the delete button;
User is able to modify the task in the list;
User is able to drag the task to change the sequence.

## Requirements
-iOS 8.0+
-Xcode 10.0+

## Installation
-CocoaPods
1. Install Cocoapods 
```sudo gem install cocoapods```

2. Set up Cocopods
```pod setup```

-Cocopods dependencies
1. Use CocoaPods to install YourProject by adding it to your Podfile:
```
platform :ios, '11.0'

target 'yourProject' do

pod 'AFNetworking'
pod 'RxSwift'
pod 'RxCocoa'

end
```

2. Open the terminal, change the directory to your project and run pod install
```pod install```
