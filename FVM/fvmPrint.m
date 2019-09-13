function fvmPrint(str,arg1,arg2,arg3)

%
% fvm output routine
%
% FVM_PARAMETERS(1) = 0,  no output
% FVM_PARAMETERS(1) = 1,  output
%

global FVM_PARAMETERS

switch FVM_PARAMETERS(1)
  case 0,
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % No output
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    return

  case 1,
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Output
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    switch nargin
      case 1,
	fprintf(str);
	return
      case 2,
	fprintf(str,arg1);
	return
      case 3,
	fprintf(str,arg1,arg2);
	return
      case 4,
	fprintf(str,arg1,arg2,arg3);
	return
      otherwise
	error('too many arguments');
	return
    end

  otherwise
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % FVM_PARAMETERS(1) incorrectly set
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    error('FVM_PARAMETERS(1) incorrectly set');
end

