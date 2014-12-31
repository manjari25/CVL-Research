clear all;
close all;
clc;

F = makeLMfilters();
for i=1:48
    figure, surf(F(:,:,i));
end