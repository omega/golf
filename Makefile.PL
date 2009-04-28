# IMPORTANT: if you delete this file your app will not work as
# expected.  you have been warned
use inc::Module::Install;

name 'Golf';
all_from 'lib/Golf.pm';

requires 'Catalyst::Runtime' => '5.80002';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Action::RenderView';
requires 'Config::General'; # This should reflect the config file format you've chosen
                 # See Catalyst::Plugin::ConfigLoader for supported formats
catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
