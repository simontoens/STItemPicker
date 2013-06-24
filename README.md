STItemPicker
==========

A generic, data-drive, multi-level, master-detail item picker controller, similar in looks to MPMediaPickerController; configurable by adopting a simple data source protocol (see `ItemPickerDataSource.h`).

The `ItemPickerSource` folder has all required source code.  The item picker API lives in `ItemPickerSource/API`.  The `DataSources` folder contains sample data source implementations, including a [data source](blob/master/STItemPicker/DataSources/MPMediaDataSource.m] for the content of a device's iPod Library.

The `ItemPicker` class is the entry point; it also has global configuration options, such as showing a cancel button.  See `TestViewController.m` for examples on how to setup and display the ItemPicker.

Run in the Simulator to get an idea of how the ItemPicker looks like.

This project uses submodules; you need to run `git submodule init` and `git submodule update` before building.
