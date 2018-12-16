clc
clf
clear
%% ��ʼ��������ȼ����������ʷ��䣬���ؿ���ѭ���Ȳ���
    MIN_SNR_dB = 0;   
    MAX_SNR_dB = 14;
    INTERVAL = 0.5;	% ����ȼ��
    POW_DIV = 1/2;  % ���ʷ������
    Monte_MAX=10^1;    % ���ؿ���ѭ������

%% ��������Ķ����Ʊ�����
    M = 3;       % ������ 
    N = 15000;   % ������
    x = randi(1,N,M);	% ��������Ʊ�����

%% bpsk����
    x_s= pskmod(x,2);%���Ʋ���Դ�ź� 

%% �����ŵ������ú�ε�����˥���ŵ�
    H_sd = RayleighCH( 1 );
    H_sr = RayleighCH( 1 );
    H_rd = RayleighCH( 1 );
    
%% In different SNR in dB
    snrcount = 0;
for SNR_dB=MIN_SNR_dB:INTERVAL:MAX_SNR_dB
	snrcount = snrcount+1;    % count for different BER under SNR_dB   
    err_num_AF = 0;% Used to count the error bit
    
    for tries=0:Monte_MAX
 
        sig = 10^(SNR_dB/10); % SNR, said non-dB
        POW_S = POW_DIV;      % Signal power
        POW_N = POW_S / sig;  % Noise power
    % AWGN:��ĳһ�ź��м����˹����
        y_sd = awgn( sqrt(POW_DIV)*H_sd * x_s, SNR_dB, 'measured');
        y_sr = awgn( sqrt(POW_DIV)*H_sr * x_s, SNR_dB, 'measured');
    % With Fixed Amplify-and-Forward relaying protocol
        [beta,x_AF] = AF(H_sr,POW_S,POW_N,y_sr);
        y_rd = awgn( sqrt(POW_S)*H_rd * x_AF, SNR_dB, 'measured');	
        y_combine_AF = Mrc( H_sd,H_sr,H_rd,beta,POW_S,POW_N,POW_S,POW_N,y_sd,y_rd);  
        y_AF = pskdemod(y_combine_AF,2); 
        err_num_AF = err_num_AF + Act_ber(x,y_AF);   % wrong number of bits with AF
    % Calculated the actual BER for each SNR %ͨ��ͳ�����ؿ��޵�����������ȫ��������Ŀ���Ա�	
	ber_AF(snrcount) = err_num_AF/(N*Monte_MAX);
    % Calculated the theoretical BER for each SNR %�����Զ��庯���õ�
    theo_ber_AF(snrcount) = Theo_ber(H_sd,H_sr,H_rd,POW_S,POW_N,POW_S,POW_N);
        
    end    % for SNR_dB=MIN_SNR_dB:INTERVAL:MAX_SNR_dB
end
%% draw BER curves 
SNR_dB = MIN_SNR_dB:INTERVAL:MAX_SNR_dB;

disp('theo_ber_AF=');disp(theo_ber_AF);%disp ������ʾ����

figure(1)  % the actual BER of Direct and AF,DF
semilogy(SNR_dB,ber_AF,'g-+');%semilogx�ð���������ͼ,x����log10��y�����Եģ�semilogy�ð���������ͼ,y����log10��x�����Ե�            
grid on; %��������
ylabel('The AVERAGE BER');
xlabel('SNR(dB)');
title('the actual BER of  AF ');
axis([MIN_SNR_dB,MAX_SNR_dB,10^(-5),1]);

figure(2)  % the theoretical BER of AF and DF
semilogy(SNR_dB,theo_ber_AF,'g-+');
grid on;
ylabel('The AVERAGE BER');
xlabel('SNR(dB)');
title('the theoretical BER of AF ');
axis([MIN_SNR_dB,MAX_SNR_dB,10^(-5),1]);

figure(3)  % the actual / theoretical BER of AF 
semilogy(SNR_dB,ber_AF,'r-o',SNR_dB,theo_ber_AF,'b-*');
legend('actual BER','theoretical BER');
grid on;
ylabel('The AVERAGE BER');
xlabel('SNR(dB)');
title('the actual / theoretical BER of AF');
axis([MIN_SNR_dB,MAX_SNR_dB,10^(-5),1]);