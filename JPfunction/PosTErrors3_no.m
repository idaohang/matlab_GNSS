function [dXYZ, dNEV] = PosTErrors3(ttPlot, TruePos, EstPosT,visiSat)
%
% function [dXYZ, dNEV] = PosTErrors(tt, TruePos, EstPosT)
%
% <input>   ttPlot: Time Tags [gs]
%           TruePos: True Position [1x3]
%           EstPosT: Estimated Positioni and Clock Error; c1-3(XYZ Estimates), c4(Clock Estimates)
%
% <output>  dXYZ: XYZ differences wrt TruePos
%           dNEV: NEV differences wrt TruePos
%
% Copyright: Kwan-Dong Park, 9/20/2014
%
%% �Է� ����� ũ�⸦ �����ϱ� ����
for i = 1:length(ttPlot)
    gs = ttPlot(i);
    VisiSat(i,:) = visiSat(find(visiSat(:,1) == gs),:);
end
%% �Է¹��� �ڷ��� ũ�� �� ������ �ش��ϴ� ���浵 ���� ����
NoPos = length(EstPosT);
gd = xyz2gd(TruePos); TrueLat = gd(1); TrueLon = gd(2); 
%% ������ XYZ�� ���� XYZ�� ���̰� ����
dXYZ = zeros(NoPos,3);
for k = 1:NoPos
    dXYZ(k,:) = EstPosT(k,1:3) - TruePos;
end
%% dXYZ�� dNEV�� ��ȯ
dNEV = xyz2topo(dXYZ, TrueLat, TrueLon);
absdNEV = abs(dNEV); Max_error = max(absdNEV(:,1:2)); Max_error = max(Max_error);
%% �� ���к� RMS ���
dN = dNEV(:,1); dE = dNEV(:,2); dV = dNEV(:,3);
[dNE dU d3] = RMS(dNEV)
 
% dNE = sqrt(dN.^2 + dE.^2);        %rmsH = myRMS(dNE);
%                                   %rmsV = myRMS(dV);
% d3 = sqrt(dN.^2 + dE.^2 + dV.^2); %rms3 = myRMS(d3);
% fprintf('RMS Values \n H:%8.2f \n V:%8.2f \n 3D:%7.2f\n', rmsH, rmsV, rms3)
%% �׷��� �׸��� �۾� ����
rXY = max([abs(min(dNEV(:,1))) abs(max(dNEV(:,1))) abs(min(dNEV(:,2))) abs(max(dNEV(:,2)))]);
rXY = ceil(rXY);
figure(66);
subplot(3,4,[1,2,5,6])
plot(dE, dN,'bo'); 
% axis([-rXY rXY -rXY rXY]); 
% axis([-5 5 -5 5]);
axis([-Max_error Max_error -Max_error Max_error]);
% axis([-ceil(dNE) ceil(dNE) -ceil(dNE) ceil(dNE)]);
axis square
grid on; 
xlabel({'\Delta E (meters)',...
    ['dNE = ', num2str(decimal(dNE))],...
    [' dV = ', num2str(decimal(dU))],...
    [' 3D = ', num2str(decimal(d3))]}); ; ylabel('\Delta N (meters)')
%% �׷��� ����
tHour = mod(ttPlot, 86400);
tHour = tHour/3600;
dT = EstPosT(:,4);
subplot(3,4,[3,4])
plot(tHour, dN, '.r-', tHour, dE, '.b-'); axis([min(tHour) max(tHour) min(dN) max(dN)]); grid on;
legend('\Delta N', '\Delta E')
ylabel('\Delta H (meters)');
subplot(3,4,[7,8])
plot(tHour, dV, 'b.-'); axis([min(tHour) max(tHour) min(dV) max(dV)]); grid on;
ylabel('\Delta V (meters)')
subplot(3,4,[11,12])
stairs(tHour, VisiSat(:,2), '-.ok'); axis tight; grid on;
xlabel('Hours'); ylabel('Visiabe Satellite');