#!/usr/bin/env perl
# IMPORTANT: if you delete this file your app will not work as
# expected.  You have been warned.
use inc::Module::Install 1.02;
use Module::Install::Catalyst;   # Complain loudly if you don't have
                                 # Catalyst::Devel installed or haven't said
                                 # 'make dist' to create a standalone tarball.

name 'MetaCPAN-Contest-Vote';
all_from 'lib/MetaCPAN/Contest/Vote.pm';

requires 'Catalyst::Runtime' => '5.90006';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Action::RenderView';
requires 'Moose';
requires 'namespace::autoclean';
requires 'Config::General';
requires 'Pithub';
requires 'Catalyst::Plugin::Authentication';
requires 'Template::Alloy';
requires 'Catalyst::View::TT::Alloy';
requires 'Catalyst::Plugin::Session';
requires 'Catalyst::Plugin::Session::State::Cookie';
requires 'Catalyst::Plugin::Session::Store::FastMmap';
requires 'XML::Feed';
requires 'MooseX::Types::URI';
requires 'Mojo::DOM';
requires 'Catalyst::Model::Adaptor';

test_requires 'Test::More' => '0.88';
catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
