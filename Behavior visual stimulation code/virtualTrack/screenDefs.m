function sDef = screenDefs()
%
%
%
%

% Created: SRO - 9/24/11



sDef.screenNum = 1; 
sDef.screenNum2 = 2;
sDef.width = 1920;
sDef.width_inches = 20.5;
sDef.height = 1080;
sDef.height_inches = 11.53;
sDef.frameRate = 60;

sDef.gain = 0.02;
sDef.solenoidOpenTime = 0.2;
sDef.solenoidShort = sDef.solenoidOpenTime/5;

% Compute some values
sDef.pixelSizeInches = sDef.width_inches/sDef.width;

% Gamma correction
sDef.gammaCorrect = 1;
sDef.a = 0.00062497; 
sDef.b = 2.3084; 