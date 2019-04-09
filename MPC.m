%% Match Presentations Construction %%
% % edit by Jiang Xingyu 2018.01
function [feature,FF,pp_inlier]=MPC(Xt,Yt,Klist)
K0=10; K1=10; K2=10;

kdtreeX = vl_kdtreebuild(Xt);
kdtreeY = vl_kdtreebuild(Yt);
[neighborX, ~] = vl_kdtreequery(kdtreeX, Xt, Xt, 'NumNeighbors', K0+1) ;
[neighborY, ~] = vl_kdtreequery(kdtreeY, Yt, Yt, 'NumNeighbors', K0+1) ;

bb = [neighborX;neighborY];
as = diff(sort(bb));
dd = (double( as==zeros(  size(as,1),size(as,2)  ) ));
count_both_point = sum(double(dd))-1;
pp_inlier = count_both_point./K0;
idx = find(pp_inlier>0.1);

kdtreeX = vl_kdtreebuild(Xt(:,idx));
kdtreeY = vl_kdtreebuild(Yt(:,idx));
[neighborX, ~] = vl_kdtreequery(kdtreeX, Xt(:,idx), Xt, 'NumNeighbors', K1+1) ;
[neighborY, ~] = vl_kdtreequery(kdtreeY, Yt(:,idx), Yt, 'NumNeighbors', K1+1) ;
neighborX = idx(neighborX);
neighborY = idx(neighborY);
bb = [neighborX;neighborY];
as = diff(sort(bb));
dd = (double( as==zeros(size(as,1),size(as,2)) ));
count_both_point = sum(double(dd))-1;
pp_inlier = count_both_point./K1;
idx = find(pp_inlier>0.3);%0.3

kdtreeX = vl_kdtreebuild(Xt(:,idx));
kdtreeY = vl_kdtreebuild(Yt(:,idx));
[neighborX, ~] =vl_kdtreequery(kdtreeX, Xt(:,idx), Xt, 'NumNeighbors', K2+1) ;
[neighborY, ~] =vl_kdtreequery(kdtreeY, Yt(:,idx), Yt, 'NumNeighbors', K2+1) ;
neighborX=idx(neighborX);neighborY=idx(neighborY);
bb=[neighborX;neighborY];
as=diff(sort(bb));
dd=(double(as==zeros(size(as,1),size(as,2))));
count_both_point=sum(double(dd))-1;
pp_inlier=count_both_point./K2;
idx=find(pp_inlier>0.5);%
% if length(idx)<=30
% idx=1:round(size(Xt,2)./2);
% end
%%************************
pp_inlier=[];
% %****************************
dv=0.0000001;
vec=Yt-Xt+dv;
d2=vec(1,:).^2+vec(2,:).^2;  % the length of the vector
sita=atan((vec(2,:)+dv)./(vec(1,:)+dv));% the derection of the vector
sita(find(sita>=0&vec(2,:)<=0)) = sita(find(sita>=0&vec(2,:)<=0))+pi;%3
sita(find(sita<=0&vec(2,:)<=0)) = sita(find(sita<=0&vec(2,:)<=0))+2*pi;%4
sita(find(sita<=0&vec(2,:)>0))  = sita(find(sita<=0&vec(2,:)>0))+pi;%2
% %**************************
% [sita,d2]=cart2pol(vec(1,:),vec(2,:));
% sita=sita+pi;
FF=zeros(2,length(sita));
%% ******************
kdtreeX = vl_kdtreebuild(Xt(:,idx));
kdtreeY = vl_kdtreebuild(Yt(:,idx));
[neighborX0, ~] = vl_kdtreequery(kdtreeX, Xt(:,idx), Xt, 'NumNeighbors', Klist(end)+1) ;
[neighborY0, ~] = vl_kdtreequery(kdtreeY, Yt(:,idx),Yt, 'NumNeighbors', Klist(end)+1) ;
for i=1:length(Klist)
K=Klist(i);
FF=zeros(2,length(sita));
%%
% [neighborX0, ~] = vl_kdtreequery(kdtreeX, Xt(:,idx), Xt, 'NumNeighbors',K+1) ;
% [neighborY0, ~] = vl_kdtreequery(kdtreeY, Yt(:,idx),Yt, 'NumNeighbors', K+1) ;
% neighborX = idx(neighborX0);
% neighborY = idx(neighborY0);
neighborX = idx(neighborX0(1:K+1,:));
neighborY = idx(neighborY0(1:K+1,:));
bb = [neighborX;neighborY];
index = sort(bb);
as = diff(index);
d2i = d2(index);
sitai = sita(index);
dd=(double(as==zeros(size(as,1),size(as,2))));

count_both_point = sum(double(dd))-1;
count_both_point(find(count_both_point<0)) = count_both_point(find(count_both_point<0))+1;
pp = count_both_point./K;
iii = find(count_both_point>0);

d2i = d2i.*[dd;zeros(1,size(dd,2))];
sitai = sitai.*[dd;zeros(1,size(dd,2))];
% d2new=sum(d2i)./(sum(double(dd))+0.000001);
% sitanew=sum(sitai)./(sum(double(dd))+0.000001);
d2new = (sum(d2i)-d2)./(sum(double(dd))-1+0.000001);
sitanew = (sum(sitai)-sita)./(sum(double(dd))-1+0.000001);
angle = abs(sita(iii)-sitanew(iii));
angle(find(angle>pi)) = 2*pi-angle(find(angle>pi));

pp_inlier(i,:) = pp;
FF(1,iii)=gaussmf(max([d2(iii)./d2new(iii);d2new(iii)./d2(iii)]),[0.4,1]);
FF(2,iii)=gaussmf(angle,[0.8,0]);
consistency(2*i-1:2*i,:)=FF;
end
feature=[pp_inlier',consistency'];