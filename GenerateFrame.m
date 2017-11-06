function [ Frame_data ] = GenerateFrame( Num_Cell_y,Num_Cell_x,Total_time,SNR_dB,Sigma_noise,x,x_dis,y_dis,Target_number)
%�����趨Ŀ���SNR��������֡����
%   �˴���ʾ��ϸ˵��
       
%% ============== Generate measurements ================  
            %% --------- Generate the measurement noise --------
            %Frame_data=zeros(Num_Cell_y,Num_Cell_x,Total_time); % Denote the Intensity of the target in the resolution cell. 
            %% ---- Rayleigh distribution   %�����ֲ�������ƽ��
            Noise_data = zeros(Num_Cell_y,Num_Cell_x,Total_time);
            for i=1:Num_Cell_x
                Noise_data(:,i,:)= raylrnd(Sigma_noise,Num_Cell_y,Total_time);
                for j=1:Num_Cell_y
                    Noise_data(j,:,:) = raylrnd(Sigma_noise,Num_Cell_x,Total_time);
                end
            end
            
            for t=1:Total_time
                Frame_data(:,:,t)=Noise_data(:,:,t);  %��������ƽ�� ��Frame_data��ʱ��ά�ȣ���Noise_data�ǰ�37��ʱ�̵�����ƽ�汣����һ����λ�����ڣ�
                
            end       
%           %% ----��˹�ֲ�����ƽ��---- %%%
%             I_noise=Sigma_noise*randn(numY,numX,Total_time);
%             Q_noise=Sigma_noise*randn(numY,numX,Total_time);
%             %
%             Frame_data=(1/2^0.5).*(I_noise+Q_noise.*(-1)^0.5);
            %% ---- Add the target signal ----
            Signal_amplitude=(10.^(SNR_dB./10)).^0.5;
            A = Signal_amplitude;
            for  n=1:Target_number 
                for t=1:Total_time
                    Frame_data(y_dis(1,n,t),x_dis(1,n,t),t) = Frame_data(y_dis(1,n,t),x_dis(1,n,t),t) +A;
                end  
            end
                
end  %����Ŀ����Ϣ