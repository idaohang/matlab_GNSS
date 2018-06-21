%
%   modified by Joonseong Gim, aug 7, 2016
%

clear all; close all;

%% GPS/GLO ����ġ ����
sys_w = [0.8, 0.2];
%% QMfile ȣ��
FileQM = 'Q160524_ubx1';

%% YY DOY �Է�
YY = 16;, DOY = 145;

%% load a PRC file
PRCfile = 'JPRT160524.t1';

%% �Һ� ���� ����: ���� �ӵ�, ����ġ
CCC = 299792458.;   % CCC = Speed of Light [m/s]
ObsType = 120;      % ����� ����ġ ���� - 120: C/A = C1

%% �Ӱ������ ����
eleCut = 15;

%% ������ǥ ����
vrsfile = '160524_1_adm.txt';
VRS = load(vrsfile);
VRS(:,1) = VRS(:,1) +17;
TruePos = VRS(1,5:7);

%% rinex file �Է�
obsfile = '160524-ubx1.obs';

%% ������� QMfile�� obsevation Rinex ���� ���� ��¥, �ð����� ����
rename = renameQMfile(obsfile);
[gw, GD] = ydoy2gwgd(YY, DOY); %: GPS WEEK ����

%% ��� ���� �Է� �� ������ ����
% --- GLONASS ��۱˵��� ���� : EphGLO, LeapSecond, TauC
FileNavGLO = strcat('brdc',num2str(DOY),'0.',num2str(YY),'g');
EphGlo = ReadEPH_GLO(FileNavGLO);
TauC = ReadTauC(FileNavGLO); %%
% --- GPS ��۱˵��� ����: ������-Klobuchar
FileNav = strcat('brdc',num2str(DOY),'0.',num2str(YY),'n');
LeapSec = GetLeapSec(FileNav); %%
%% GPS QM ���� �о�鿩�� ��ķ� �����ϰ�, ����� ����ġ ����
[arrQM, FinalPRNs, FinalTTs] = ReadQM(FileQM);
QMGPS = SelectQM(arrQM, ObsType);       % GPS C1
QMGLO = SelectQM(arrQM, 320);           % GLO C1
FinalQM = [QMGPS; QMGLO];               % GPS/GLO C1
FinalTTs = intersect(unique(FinalQM(:,1)), VRS(:,1));

[GPSPRC, GLOPRC, PRC_sorted] = PRCsort(PRCfile, FinalQM);

%% �׹��޽����� �о�鿩�� ��ķ� �����ϰ�, Klobuchar �� ����
eph = ReadEPH(FileNav);
[al, be] = GetALBE(FileNav);
%% ���̳ؽ� ���Ͽ��� �뷫���� ������ ��ǥ�� �̾Ƴ��� ���浵�� ��ȯ
% AppPos = [-3041241.741 4053944.143 3859873.640];   % : JPspace B point
AppPos = GetAppPos(obsfile);
if AppPos(1) == 0
    AppPos = TruePos;
end

gd = xyz2gd(AppPos); AppLat = gd(1); AppLon = gd(2);

%% ������ �ʿ��� �ʱ�ġ ����
MaxIter = 10;
EpsStop = 1e-5;
ctr = 1; deltat = 1;

%% �������� ����
NoEpochs = length(FinalTTs);
EstPos = zeros(NoEpochs,5);
nEst = 0;
j=1;
estm = zeros(NoEpochs,6);
visiSat = zeros(NoEpochs,2);
GPS0_c = zeros(NoEpochs,32);
GLOo_c = zeros(NoEpochs,24);

% load('DGPSCPtest.mat')
% TruePos = [-3032234.51900000,4068599.11300000,3851377.46900000];

x = [AppPos ctr ctr]; x = x';
x_d = [AppPos ctr ctr]; x_d = x_d';


for j = 1:NoEpochs
    gs = FinalTTs(j);
    indexQM = find(FinalQM(:,1) == gs);         % gs epoch�� QM
    indexPRC = find(PRC_sorted(:,1) == gs);      % gs epoch�� PRC(GPS/GLO)
    QM1 = FinalQM(indexQM,:);           % GPS/GLO C1 1 Epoch
    PRC1 = PRC_sorted(indexPRC,:);
    NoSats = length(QM1(:,1));
    vec_site = x(1:3)';
    vec_site_d = x_d(1:3)';
    GpsQM = find(QM1(:,3) == 120); GpsSats = length(GpsQM);     % GPS C1
    GloQM = find(QM1(:,3) == 320); GloSats = length(GloQM);     % GLO C1
    visiSat(j,1) = gs; visiSat(j,2) = NoSats; visiSat(j,3) = GpsSats; visiSat(j,4) = GloSats;
    sT= mod(gs,86400)/3600;
    sTh = floor(sT); sTm = sT - sTh;
    sys_w = [GpsSats/NoSats+0.1, GloSats/NoSats-0.1];           % �׹��ý��� ����ġ���� ��ü �������� ���� �� �ý��� ����
    if j == 1 % ���۽ð� ���� ��ġ array
        %         [Sat_ar] = GetSatPosGLO_new(EphGlo,gs,deltat);
        [Sat_ar] = GetSatPosGLO_my(EphGlo,gs,deltat);
        %         fprintf('���� �ð� ��ġ ���\n');
    elseif (j ~= 1 && sTm == 0) % ������ ��
        clear Sat_ar
        %         [Sat_ar] = GetSatPosGLO_new(EphGlo,gs,deltat);
        [Sat_ar] = GetSatPosGLO_my(EphGlo,gs,deltat);
        %         fprintf('%d�� ���� ����\n',sTh);
    elseif (j ~= 1 && mod(sTm,0.5) == 0) % 30�� �� ��
        clear Sat_ar
        %         [Sat_ar] = GetSatPosGLO_new(EphGlo,gs,deltat);
        [Sat_ar] = GetSatPosGLO_my(EphGlo,gs,deltat);
        %         fprintf('%d�� 30�� ����\n',sTh);
    end
    
    ZHD = TropGPTh(vec_site, gw, gs);
    for Iter = 1:MaxIter
        HTH = zeros(5,5);                   % PP
        HTH_d = zeros(5,5);                 % DGNSS
        HTy = zeros(5,1);                   % PP
        HTy_d = zeros(5,1);                 % DGNSS
        
        for i = 1:NoSats
            prn = QM1(i,2); type = QM1(i,3); obs = QM1(i,4);
            if type == 120
                prc = PRC1(find(PRC1(:,2) == prn+100),3);               % DGPS PRC
                if ~isempty(prc)
                    icol = PickEPH(eph, prn, gs);
                    toe = eph(icol, 8); a = eph(icol, 19); b = eph(icol, 20); c = eph(icol, 21); Tgd = eph(icol, 23);
                    %----- ��ȣ���޽ð� ���
                    STT = GetSTTbrdc(gs, prn, eph, x(1:3)');                % GPS PP
                    STT_d = GetSTTbrdc(gs, prn, eph, x_d(1:3)');            % DGPS
                    tc = gs - STT;                                          % GPS PP
                    tc_d = gs - STT_d;                                        % DGPS
                    %----- �����˵� ���
                    vec_sat = GetSatPosNC(eph, icol, tc);                   % GPS PP
                    vec_sat_d = GetSatPosNC(eph, icol, tc_d);               % DGPS
                    vec_sat = RotSatPos(vec_sat, STT);                      %: GPS PP �������� ����
                    vec_sat_d = RotSatPos(vec_sat_d, STT_d);                  %: DGPS �������� ����
                    %----- ���� RHO ���� ���
                    vec_rho = vec_sat - x(1:3)';                            % GPS PP
                    vec_rho_d = vec_sat_d - x_d(1:3)';                      % DGPS
                    rho = norm(vec_rho);                                    % GPS
                    rho_d = norm(vec_rho_d);                                % DGPS
                    [az,el] = xyz2azel(vec_rho, AppLat, AppLon);
                    
                    if el >= eleCut %15
                        W = 1;
%                         W = MakeW_elpr(el);
                        
                        dRel = GetRelBRDC(eph, icol, tc);                   % GPS PP
                        dRel_d = GetRelBRDC(eph, icol, tc_d);               % DGPS
                        dtSat = a + b*(tc - toe) + c*(tc - toe)^2 - Tgd + dRel;                 % GPS PP
                        dtSat_d = a + b*(tc_d - toe) + c*(tc_d - toe)^2 - Tgd + dRel_d;         % DGPS
                        dIono = ionoKlob(al, be, gs, az, el, vec_site);                 % Klobuchar
                        dTrop_G = ZHD2SHD(gw, gs, vec_site, el, ZHD);                   % GPT model
                        com = rho + x(4)  - CCC * dtSat + dIono + dTrop_G;              % GPS PP(Klobuchar, GPT Model)
                        com_d = rho_d + x(4)  - CCC * dtSat_d - prc;                    % DGPS
                        y = obs - com;                                          % GPS PP
                        y_d = obs - com_d;                                      % DGPS
                        H = [ -vec_rho(1)/rho -vec_rho(2)/rho -vec_rho(3)/rho 1 0];                  % GPS PP
                        H_d = [ -vec_rho_d(1)/rho_d -vec_rho_d(2)/rho_d -vec_rho_d(3)/rho_d 1 0];    % DGPS
                        HTH = HTH + H'*W*sys_w(1)*H;                         % GPS PP
                        HTH_d = HTH_d + H_d'*W*sys_w(1)*H_d;                 % DGPS
                        HTy = HTy + H'*W*sys_w(1)*y;                         % GPS PP
                        HTy_d = HTy_d + H_d'*W*sys_w(1)*y_d;                 % DGPS
                    end
                end
            else
                
                % --- �������� ����� ������ ���: ����ũ�� �� �� ���
                prc = PRC1(find(PRC1(:,2) == prn+300),3);
                if ~isempty(prc)
                    tc = gs - LeapSec;
                    icol=PickEPH_GLO2(EphGlo, prn, tc);
                    
                    TauN=EphGlo(icol,12); GammaN=EphGlo(icol,13); %: tau & gamma �ð���� ������ ���
                    ch_num=EphGlo(icol,16); %: channel number ������ ������ ���
                    
                    % ��ȣ���޽ð� ���
                    STT = GetSTTbrdcGLO2(Sat_ar,gs,prn,x(1:3));                 % GLO PP
                    STT_d = GetSTTbrdcGLO2(Sat_ar,gs,prn,x_d(1:3));             % DGLO
                    % LeapSecond & ��ȣ���� �ð��� ������ ���� ��ġ ����
                    [SatPos, SatVel] = SatPosLS_STT(Sat_ar,gs,prn,LeapSec,STT,TauC);            % GLO PP
                    [SatPos_d, SatVel_d] = SatPosLS_STT(Sat_ar,gs,prn,LeapSec,STT_d,TauC);      % DGLO
                    
                    % ���� ����ȿ�� ����
                    SatPos = RotSatPos(SatPos,STT);                     % GLO PP
                    SatPos_d = RotSatPos(SatPos_d,STT_d);               % DGLO
                    %             SatPos = SatPos';
                    
                    DistXYZ = SatPos - x(1:3)';                         % GLO PP
                    DistXYZ_d = SatPos_d - x_d(1:3)';                       % DGLO
                    DistNorm = norm(DistXYZ);                           % GLO PP
                    DistNorm_d = norm(DistXYZ_d);                       % DGLO
                    [az,el] = xyz2azel(DistXYZ, AppLat, AppLon);
                    %%
                    if el>=eleCut
                        % ������ ���� % ����� ����
                        W = 1;
%                         W = MakeW_elpr(el);
                        
                        ttc = tc - TauC;                                    % GLO PP
                        dIono = Klo_R(vec_site,al,be,ttc,SatPos,ch_num);
                        dTrop = ZHD2SHD(gw,gs,vec_site,el,ZHD);
                        % ����� ȿ�� (�������ӵ� �̿�)
                        dRel = (-2/CCC^2) * dot(SatPos, SatVel);            % GLO PP
                        dRel_d = (-2/CCC^2) * dot(SatPos_d, SatVel_d);      % DGLO
                        % DCB ����
                        %                     dDCB = AppDCB_glo(DCB,prn-200);
                        %%
                        % �����ð���� tsv, tb
                        tsv = tc;                                           % GLO PP
                        tsv_d = tc;                                       % DGLO
                        tb = EphGlo(icol,2) + LeapSec; % GPStime - 16; / GLOtime + 16; Ȯ���ϱ�
                        %                 dtSat = TauN - GammaN*(tsv-tb) + TauC + dRel + dDCB;
                        dtSat = TauN - GammaN*(tsv-tb) + TauC + dRel;           % GLO PP
                        dtSat_d = TauN - GammaN*(tsv_d-tb) + TauC + dRel_d;   % DGLO
                        
                        com = DistNorm + x(5) - CCC*dtSat + dTrop + dIono;      % GLO PP
                        com_d = DistNorm_d + x(5) - CCC*dtSat_d ;          % DGLO
                        
                        y = obs - com;                                          % GLO PP
                        y_d = obs - com_d;                                      % DGLO
                        H = [-DistXYZ(1)/DistNorm -DistXYZ(2)/DistNorm -DistXYZ(3)/DistNorm 0 1];               % GLO PP
                        H_d = [-DistXYZ_d(1)/DistNorm_d -DistXYZ_d(2)/DistNorm_d -DistXYZ_d(3)/DistNorm_d 0 1]; % DGLO
                        HTH = HTH + H'*W*sys_w(2)*H;                     % GLO PP
                        HTH_d = HTH_d + H_d'*W*sys_w(2)*H_d;             % DGLO
                        HTy = HTy + H'*W*sys_w(2)*y;                     % GLO PP
                        HTy_d = HTy_d + H_d'*W*sys_w(2)*y_d;             % DGLO
                    end
                end
            end
        end
        
        xhat = inv(HTH) * HTy;                              % PP
        xhat_d = inv(HTH_d) * HTy_d;                        % DGNSS
        x = x + xhat;                                       % PP
        x_d = x_d + xhat_d;                                 % DGNSS
        
        if norm(xhat) < EpsStop;
            nEst = nEst + 1;
            estm(nEst,1) = gs;                              % PP
            estm_d(nEst,1) = gs;                            % DGNSS
            estm(nEst,2:5) = x(1:4);                        % PP
            estm_d(nEst,2:5) = x_d(1:4);                      % DGNSS
            fprintf('gs: %6.0f     %2.1f    %2.1f \n',gs,norm(TruePos'-x(1:3)),norm(TruePos'-x_d(1:3)));
            break;
        end
    end
end
estm = estm(1:nEst,:);
%% �������� �м� & �׷��� �ۼ�
UBLOX(:,1) = VRS(:,1);
UBLOX(:,2:4) = VRS(:,5:7);
[dXYZ, dNEV] = PosTErrors5(estm, UBLOX, visiSat);
[dXYZ_d, dNEV_d] = PosTErrors5(estm_d, UBLOX, visiSat);