function [dx] = fvmCalcDX(mesh)

d = fvmDiameters(mesh,'ifnecessary');

dx = min(d);
