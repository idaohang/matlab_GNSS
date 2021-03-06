% function [qm] = WriteAndroid(filename)
%
%   function [] = WriteAndroid(filename)
%   Read the given logged Android file and make a 'QMfile'
%
%   ex) WriteAndroid('pseudoranges_log_2017_02_14_18_58_59.txt');
%
%   Coded by Joonseong Gim, Feb 16, 2017
%
%   추가 사항 : Raw Measurement 중 State값이 가장 큼에도 불구하고 PseudoRange 값이 이상한 위성이
%   생성되는것을 발견함.
%   그래서 86번째 라인 if bitand(State,2^0) &  bitand(State,2^3)를 추가하여 State 값을
%   판단함(첫Bit와 4번째 Bit가 모두 1이상)

clear all
close all
% filename = 'pseudoranges_log_2017_02_14_18_58_59.txt';
% filename = 'pseudoranges_log_2017_03_02_15_33_59.txt';      % 교수님이 받아주신 자료
% filename = 'pseudoranges_log_2017_08_01_15_39_28.txt';      % 대성 B 지점 수평
% filename = 'pseudoranges_log_2017_08_01_15_50_15.txt';      % 대성 B 지점 뒤집어서
% filename = 'pseudoranges_log_2017_08_01_16_02_35.txt';      % 대성 B 지점 수직 세로
% filename = 'pseudoranges_log_2017_08_01_16_14_00.txt';      % 대성 B 지점 수직 가로
% filename = 'pseudoranges_log_2017_09_14_16_31_57.txt';      % 대성 B 지점 1
% filename = 'pseudoranges_log_2017_09_14_16_42_37.txt';      % 대성 B 지점 2
% filename = 'pseudoranges_log_2017_09_14_16_53_37.txt';      % 대성 B 지점 3
% filename = 'pseudoranges_log_2017_09_14_17_04_08.txt';      % 대성 B 지점 4
% filename = 'pseudoranges_log_2017_09_14_17_14_31.txt';      % 대성 B 지점 5
% filename = 'pseudoranges_log_2017_09_14_17_25_10.txt';      % 대성 B 지점 6
% filename = 'pseudoranges_log_2017_09_14_17_36_04.txt';      % 대성 B 지점 7
% filename = 'pseudoranges_log_2017_09_14_17_46_35.txt';      % 대성 B 지점 8
% filename = 'pseudoranges_log_2017_09_14_17_57_01.txt';      % 대성 B 지점 9
% filename = 'pseudoranges_log_2017_09_14_18_08_57.txt';      % 대성 B 지점 10
% filename = 'pseudoranges_log_2017_09_19_09_39_30.txt';      % 대성 Round
% filename = 'pseudoranges_log_2017_09_19_09_41_27.txt';      % 대성 Round
% filename = 'pseudoranges_log_2017_10_13_14_46_27.txt';
% filename = 'gnss_log_2018_01_09_17_16_24.txt';
% filename = 'S8_gnss_log_2018_03_05_14_25_35.txt';       % 2018-03-05 F point
% filename = 'S8_B_gnss_log_2018_05_15_15_14_46.txt';    % 2018-05-15 S8
% filename = 'S8_B_gnss_log_2018_05_17_10_48_53.txt';        % 2018-05-17 S8
% filename = 'S8_B_gnss_log_2018_05_25_08_06_05.txt';      % 2018-05-25 S8
% filename = 'gnss_log_2018_05_25_10_27_43.txt';      % 2018-05-25 Nexus9
% filename = 'S8_B_gnss_log_2018_05_27_17_10_57.txt';      % 2018-05-27 S8
% filename = 'S8_B_gnss_log_2018_05_28_11_06_51.txt';     % 2018-05-28 S8
% filename = 'pseudoranges_log_2016_10_05_14_09_43.txt';      % 2016-10-05 Nexus9
% filename = 'S8_B_gnss_log_2018_05_28_14_15_35.txt';     % 2018-05-28 S8 2
% filename = 'N_B_gnss_log_2018_05_28_14_15_34.txt';     % 2018-05-28 S8 2
% filename = 'N8_IH_gnss_log_2018_05_29_10_54_40.txt';    % 2018-05-29 Inha Note8
% filename = 'N9U_B_gnss_log_2018_05_29_10_07_30.txt';    % 2018-05-29 NEXUS9 down
% filename = 'N9D_B_gnss_log_2018_05_29_11_14_20.txt';    % 2018-05-29 NEXUS9 up
% filename = 'N9_SH_D_gnss_log_2018_05_30_21_30_29.txt';    % 2018-05-30 NEXUS9 up 신항
% filename = 'N9_SH_U_gnss_log_2018_05_30_20_45_37.txt';    % 2018-05-30 NEXUS9 down 신항
filename = 'S8_SH_gnss_log_2018_05_30_20_32_58.txt';    % 2018-05-30 S8 신항
%% 고정 상수
CCC = 299792458;                                    % Speed of Light
WeekSecond = 604800;                                % Week Second
%% Type 구분 상수
C1 = 20;                                                                 % Code
C1PrSigmaM = 21;                                                         % PrSigmaM
C1prrSigmaMps = 22;                                                      % PseudorangeRateUncertaintyMetersPerSecond
L1 = 11;                                                                 % reserved
D1 = 31;                                                                 % Dopller
S1 = 41;                                                                 % SNR
U1 = 51;                                                                 % Uncertainty

%% GLONASS Freq Num
FCN=[1;-4;5;6;1;-4;5;6;-6;-7;0;-1;-2;-7;0;-1;4;-3;3;2;4;-3;3;2];
%% text 파일 열기 및 QMfile 선언
fid = fopen(filename,'r');
fid_out = fopen('QMfile','w');
fid_out2 = fopen('QMstate','w');

%% header 삭제 과정
ready = 0;
while ready == 0
    s = fgets(fid);
    if length(s) > 100
        if ~isempty(strfind(s,'ElapsedRealtimeMillis'))
            disp('Delete Header');
            ready = 1;
        end
    end
end
%% QMfile 생성 과정 시작
cnt = 0; cnt2=1; Epoch = 0; FirstState = 0;
while 1
    line = fgets(fid);
    gga = {};
    %    while 1
    %% line을 읽은 후 원시데이터인지 확인해서 cell로 만드는 과정
    if length(line) >= 72
        if line(1:3) == 'Raw'
            cnt = cnt + 1;
            gga = strsplit(line,',');       % GGA cell array
            if length(gga) == 20
                GGA = textscan(line(1:end),'%s%f%d64%f%f%d64%f%f%f%f%f%f%f%f%d64%d64%f%f%f%f%f%f%f%f%f%f%f%f%f','delimiter',',');
            else
                GGA = textscan(line(1:end),'%s%f%d64%f%f%d64%f%f%f%f%f%f%f%f%d64%d64%f%f%f%f%f%f%f%f%f%f%f%f%f%f','delimiter',',');
            end
            %% 만들어진 cell을 가지고 각 항목으로 분리하는 과정
            TimeNanos = GGA{3};
            TimeOffsetNanos =  GGA{13};
            FullBiasNanos = GGA{6};
            BiasNanos = GGA{7};
            ReceivedSvTimeNanos = GGA{15};
            ReceivedSvTimeUncertaintyNanos = GGA{16};
            State = GGA{14};
            %% 항법시스템 구분을 위한 Indicator
            %% 1=GPS, 2=SBAS, 3=GLONASS, 4=QZSS, 5=BeiDou, 6=Galileo, 0=Unknown
            ConstellationNum = GGA{29};                                             % Constellation Num
            %% 항법시스템에 따른 QMfile type 값 단위 설정
            switch ConstellationNum
                case 1
                    TYPE = 100;                                                                 % GPS
                    f = 1575.42e6;
                    WL = CCC/f;
                case 5
                    TYPE = 200;                                                                 % BDS
                    f = 1589.74e6;
                    WL = CCC/f;
                case 3
                    TYPE = 300;                                                                 % GLO
                case 4
                    TYPE = 400;                                                                 % GLO
                otherwise
                    TYPE = 600;                                                                 % ETC
            end
            %% 두번째 Epoch부터 PseudoRange 계산
            if bitand(State,2^0) &  bitand(State,2^3)
                %% tRxNanos를 계산하기 위한 첫 epoch의 FullBaisNanos 저장
                if cnt2 == 1
                    FullBiasNanosFirstEpoch = int64(FullBiasNanos);
                    FirstState = State;
                end
            end
            if bitand(State,2^0) &  bitand(State,2^3) & cnt >= 1
                %% 원시데이터를 numeric type에 맞추는 과정
                TimeNanos = GGA{3};                                                         % TimaNanos
                TimeOffsetNanos =  GGA{13};                                                 % TimeOffsetNanos
                FullBiasNanos = GGA{6};                                                     % FullBiasNanos
                BiasNanos = GGA{7};                                                         % BiasNanos
                ReceivedSvTimeNanos = GGA{15};                                              % ReceivedSvTimeNanos
                ReceivedSvTimeUncertaintyNanos = GGA{16};                                   % ReceivedSvTimeUncertaintyNanos
                PrSigmaM = double(ReceivedSvTimeUncertaintyNanos)*1e-9*CCC;                 % PrSigmaM
                PseudorangeRateMetersPerSecond = double(GGA{18});                           % PseudorangeRateMetersPerSecond
                PseudorangeRateUncertaintyMetersPerSecond = double(GGA{19});                % PseudorangeRateUncertaintyMetersPerSecond
                CNo = GGA{17};                                                              % C/No(SNR)
                PRN = GGA{12};                                                              % PRN(SvID)
                AccumulatedDeltaRangeMeters = GGA{21};
                %% GLONASS에서 FCN인 경우
                if ConstellationNum == 3 & PRN > 24
                    PRN = PRN - 92;
                end
                %% GLONASS Doppler 계산을 위한 FCN 설정 및 WL계산
                if TYPE == 300
                    f = (1602 + FCN(PRN) * 0.5625) * 1e6;
                    WL = CCC / f;
                end
                Doppler = -PseudorangeRateMetersPerSecond / WL;                              % Doppler Measurement
                WeekNumber = floor(-double(FullBiasNanos)*1e-9/WeekSecond);                 % WeekNumber
                WeekNumberNanos = int64(WeekNumber)*int64(WeekSecond*1e9);                  % WeekNumberNanos
                allRxMillisecond = (((TimeNanos-FullBiasNanos)*1e-6));                      % allRxMillisecond
                FctSeconds = double(allRxMillisecond)*1e-3;                                 % Full cycle time tag of M batched measurements
                
                %% Pseudorange 생성 과정
                %% compute tRxNanos using gnssRaw.FullBiasNanos(1), so that tRxNanos includes rx clock drift since the first epoch:
                tRxNanos = (TimeNanos+TimeOffsetNanos)-(FullBiasNanosFirstEpoch+BiasNanos)-WeekNumberNanos;     % tRxNanos
                tRxSeconds = double(tRxNanos)*1e-9;                                                             % tRxNanos : nano sec -> sec
                if ConstellationNum == 3
                    %% GLONASS 는 Time of day를 사용하며, Moscov 는 UTC 기준 3시간 빠름, 윤초 18초 고려
                    Pseudorangeinsecond = tRxSeconds-(double(ReceivedSvTimeNanos)*1e-9+86400*fix(tRxSeconds/86400)...
                        - 3600*3 +18);                              % Pseudorange in sacond(ms)
                elseif ConstellationNum ~= 3
                    Pseudorangeinsecond = tRxSeconds-double(ReceivedSvTimeNanos)*1e-9;                              % Pseudorange in sacond(ms)
                end
                %% Week Rollover 문제 해결을 위한 과정
                iRollover = Pseudorangeinsecond > WeekSecond/2;
                if any(iRollover)
                    disp('WARNING: week rollover detected in time tags. Adjusting')
                    prS = Pseudorangeinsecond(iRollover);
                    delS = round(prS/WeekSecond)*WeekSecond;
                    prS = prS - delS;
                    maxBiasSecond = 10;
                    if any(prS>maxBiasSecond)
                        disp('Failed to correct week rollover')
                    else
                        Pseudorangeinsecond(iRollover) = prS;
                        tRxNanos(iRollover) = tRxNanos(iRollover) - delS;
                        disp('Corrected week rollover')
                    end
                end
                %% Pseudorange 및 CarreirPhaseCounter 생성 과정
                Pseudorange = Pseudorangeinsecond*CCC;                                              % Pseudorange(m)
                CarreirPhaseCount = 0;                                                              % reserved
                
                %% QMfile 생성
                if tRxNanos >= 0
                    %             fprintf(fid_out,'%8.3f %4d %5d %16.3f \n',tRxSeconds, PRN + TYPE, C1 + TYPE, Pseudorange);
                    %             fprintf(fid_out,'%8.3f %4d %5d %16.3f \n',tRxSeconds, PRN + TYPE, L1 + TYPE, AccumulatedDeltaRangeMeters);
                    %             fprintf(fid_out,'%8.3f %4d %5d %16.3f \n',tRxSeconds, PRN + TYPE, S1 + TYPE, CNo);
                    fprintf(fid_out,'%8.9f %4d %5d %16.7f \n',tRxSeconds, PRN, C1 + TYPE, Pseudorange);
                    fprintf(fid_out,'%8.9f %4d %5d %16.11f \n',tRxSeconds, PRN, L1 + TYPE, AccumulatedDeltaRangeMeters);
                    fprintf(fid_out,'%8.9f %4d %5d %16.3f \n',tRxSeconds, PRN, D1 + TYPE, Doppler);
                    fprintf(fid_out,'%8.9f %4d %5d %16.3f \n',tRxSeconds, PRN, S1 + TYPE, CNo);
                    fprintf(fid_out,'%8.9f %4d %5d %16.8f \n',tRxSeconds, PRN, C1PrSigmaM + TYPE, PrSigmaM);
                    fprintf(fid_out2,'%8.9f %4d %5d\n',tRxSeconds, PRN, GGA{20});
                    %                     fprintf(fid_out,'%8.3f %4d %5d %16.10f \n',tRxSeconds, PRN, C1prrSigmaMps + TYPE, PseudorangeRateUncertaintyMetersPerSecond);
                    qm(cnt2,1:4) = [tRxSeconds, PRN + TYPE, C1 + TYPE, Pseudorange];
                    States(cnt2, 1:3) = [tRxSeconds, PRN + TYPE, GGA{20}];
                    cnt2=cnt2+1;
                    qm(cnt2,1:4) = [tRxSeconds, PRN + TYPE, S1 + TYPE, CNo];
                    cnt2=cnt2+1;
                    %         qm(cnt2,1:4) = [tRxSeconds, PRN + TYPE, U1 + TYPE, double(PrSigmaM)];
                    qm(cnt2,1:4) = [tRxSeconds, PRN + TYPE, L1 + TYPE, AccumulatedDeltaRangeMeters];
                    cnt2=cnt2+1;
                    qm(cnt2,1:4) = [tRxSeconds, PRN + TYPE, D1 + TYPE, Doppler];
                    cnt2=cnt2+1;
                    qm(cnt2,1:4) = [tRxSeconds, PRN + TYPE, C1PrSigmaM + TYPE, PrSigmaM];
                    cnt2=cnt2+1;
                    %                     qm(cnt2,1:4) = [tRxSeconds, PRN + TYPE, C1prrSigmaMps + TYPE, PseudorangeRateUncertaintyMetersPerSecond];
                    %                     cnt2=cnt2+1;
                end
                
            end
        end
    elseif length(line) > 1 & line(1:3) == 'Fix'
        Epoch = Epoch + 1;
        disp(['*** Epoch = ', num2str(Epoch)])
    end
    %% While 문 종료
    if line == -1, break;  end
end
fclose('all');