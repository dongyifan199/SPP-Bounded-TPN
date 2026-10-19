%% RUN_TESTS
clear; clc;
root=fileparts(mfilename('fullpath'));
addpath(root,fullfile(root,'models'),fullfile(root,'tests'));
run_all_tests();
