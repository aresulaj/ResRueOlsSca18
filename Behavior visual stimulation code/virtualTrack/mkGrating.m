
function tmp=mkGrating(size,background_pix_val,angle,contrast)

%AR on 1/14/2014

sDef=screenDefs;
sf= 0.008;  %4 cycles/500 pixels

%360 == blank
if angle==360
   contrast=0;
end

lum_max=sDef.a*(255^sDef.b);
lum_b= 100; 
gray=floor(exp(log(lum_b/sDef.a)/sDef.b));
inc = lum_b*contrast;

nsteps=7;
step=round(1/(nsteps*sf));
phase_v=0:step:(step*(nsteps-1));
phase=phase_v(randi(length(phase_v)));
%phase= -4; %0 - leading edge is black, or 63 - leading edge is white

[x,z]=meshgrid(-size/2:1:size/2); %size = obj.size +1;
lum_y=lum_b+(sin(2*pi*sf*(x-phase))*inc.*Circle(size/2+0.5)); %.*exp(-((x/150).^2)-((z/150).^2)));
y=exp(log(lum_y/sDef.a)/sDef.b);

if angle==1
lum_y=lum_max*Circle(size/2+0.5); %.*exp(-((x/150).^2)-((z/150).^2)));
y=exp(log(lum_y/sDef.a)/sDef.b);
elseif angle==2
lum_y=1*Circle(size/2+0.5); %.*exp(-((x/150).^2)-((z/150).^2)));
y=exp(log(lum_y/sDef.a)/sDef.b);  
end

tmp=imrotate(y,angle);
tmp(tmp==0)=gray;

end
